import 'dart:io';
import 'dart:ui' as ui;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store_management_system/components/pallet_components.dart';
import 'package:store_management_system/models/color_model.dart';
import 'package:store_management_system/models/pallet_model.dart';
import 'package:store_management_system/services/api_services.dart';
import 'package:store_management_system/utils/main_utils.dart';
import 'package:store_management_system/view/pallet/pallet_details.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

//TODO: Amend signature validation

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> with TickerProviderStateMixin {
  final GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();
  List<Pallet> jobAssignedList = List.empty(growable: true);
  List<Pallet> jobConfirmList = List.empty(growable: true);
  List<Pallet> jobLoadList = List.empty(growable: true);

  String signatureErr = "";
  late TabController _tabController;
  bool? _signature;
  bool isAccess = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getAssignedJob();
    getConfirmJob();
    getJobLoads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getAssignedJob() async {
    List<dynamic>? res = await ApiServices.pallet.fetchAssignedJob();

    if (res != null && res.isNotEmpty) {
      jobAssignedList = res.map((e) => Pallet.fromMap(e)).toList();
    }

    setState(() {});
  }

  getConfirmJob() async {
    List<dynamic>? res = await ApiServices.pallet.fetchConfirmedJob();

    if (res != null && res.isNotEmpty) {
      jobConfirmList = res.map((e) => Pallet.fromMap(e)).toList();
    }

    setState(() {});
  }

  getJobLoads() async {
    List<dynamic>? res = [];

    res = await ApiServices.pallet.fetchLoadingJob();
    if (res != null && res.isNotEmpty) {
      jobLoadList.addAll(res.map((e) => Pallet.fromMap(e)));
    }

    res = await ApiServices.pallet.fetchLoadedJob();
    if (res != null && res.isNotEmpty) {
      jobLoadList.addAll(res.map((e) => Pallet.fromMap(e)));
    }

    setState(() {});
  }

  confirmJob(int palletActivityId) async {
    bool res = await ApiServices.pallet.confirmJob(palletActivityId);
    if (mounted) {
      if (res != true) {
        customShowToast(
          context,
          "Failed to confirm job, Please try again.",
          Colors.red.shade300,
        );
        return;
      }
      customShowToast(
        context,
        "Confirm job succeed.",
        Colors.blue.shade300,
      );
    }
    setState(() {});
  }

  loadJob(int palletActivityId) async {
    bool res = await ApiServices.pallet.load(palletActivityId);
    if (mounted) {
      if (res != true) {
        customShowToast(
          context,
          "Failed to load pallet to truck, Please try again.",
          Colors.red.shade300,
        );
      }
      customShowToast(
        context,
        "The pallet in loading to truck process.",
        Colors.blue.shade300,
      );
    }
    setState(() {});
  }

  closePallet(int palletActivityId) async {
    bool res = await ApiServices.pallet.close(palletActivityId);
    if (mounted) {
      if (res != true) {
        customShowToast(
          context,
          "Failed to close pallet, Please try again.",
          Colors.red.shade300,
        );
      }
      customShowToast(
        context,
        "Close pallet to succeed.",
        Colors.blue.shade300,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // job assign content tab
    Widget jobAssignedContent(index) => Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Material(
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                side: BorderSide(width: 0.3, color: Colors.grey.shade600)),
            elevation: 5,
            color: Colors.white,
            child: ListTile(
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PalletDetailsView(
                          palletActivityId:
                              jobAssignedList[index].palletActivityId)),
                );
              },
              title: Text(
                jobAssignedList[index].palletNo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "${jobAssignedList[index].openPalletLocation.capitalizeOnly()}\n${jobAssignedList[index].status}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
              ),
              trailing: IconButton(
                onPressed: () => moveToConfirmDialogBox(
                    jobAssignedList[index].palletActivityId),
                icon: const Icon(
                  FluentIcons.clipboard_task_add_24_filled,
                  size: 35,
                ),
              ),
            ),
          ),
        );

    // confirm job content tab
    Widget confirmJobContent(index) => Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  side: BorderSide(width: 0.3, color: Colors.grey.shade600)),
              elevation: 5,
              color: customCardColorStatus(jobConfirmList[index].status),
              child: ListTile(
                isThreeLine: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => PalletDetailsView(
                              palletActivityId:
                                  jobConfirmList[index].palletActivityId,
                            )),
                  );
                },
                title: Text(
                  jobConfirmList[index].palletNo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "${jobConfirmList[index].openPalletLocation.capitalizeOnly()}\n${jobConfirmList[index].status}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                ),
                trailing: IconButton(
                  onPressed: () => moveToLoadDialogBox(
                      jobConfirmList[index].palletActivityId),
                  icon: const Icon(
                    FluentIcons.clipboard_arrow_right_24_filled,
                    size: 35,
                  ),
                ),
              )),
        );

    // pallet loading and loaded content tab
    Widget jobLoadsContent(index) => Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Material(
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                side: BorderSide(width: 0.3, color: Colors.grey.shade600)),
            elevation: 5,
            color: (jobLoadList[index].status == 'Loading To TruckTruck')
                ? customCardColorStatus('Loading To TruckTruck')
                : customCardColorStatus('Loaded To Truck/Close Pallet'),
            child: ListTile(
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PalletDetailsView(
                            palletActivityId:
                                jobLoadList[index].palletActivityId,
                          )),
                );
              },
              title: Text(
                jobLoadList[index].palletNo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "${jobLoadList[index].openPalletLocation.capitalizeOnly()}\n${jobLoadList[index].status}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
              ),
              trailing: (jobLoadList[index].status == 'Loading To TruckTruck')
                  ? IconButton(
                      onPressed: () => closePalletDialogBox(index),
                      icon: const Icon(
                        FluentIcons.clipboard_more_24_filled,
                        size: 35,
                      ),
                    )
                  : const Icon(
                      FluentIcons.clipboard_checkmark_24_filled,
                      size: 35,
                    ),
            ),
          ),
        );

    // Create Tab categories; Assigned, Confirmed, Loadin/loaded
    Widget palletCategories() {
      Widget appBarTitle = const Text(
        "Today's Jobs",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );

      return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: appBarTitle,
            ),
            backgroundColor: AppColor().milkWhite,
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColor().blueZodiac,
              indicatorColor: AppColor().blueZodiac,
              tabs: const <Widget>[
                Tab(
                  child: Text(
                    'Job Assigned',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Confirm Job',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Loading/Loaded',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                color: AppColor().milkWhite,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: jobAssignedList.isEmpty
                      ? const Center(child: Text('No job assign for today'))
                      : ListView.builder(
                          itemCount: jobAssignedList.length,
                          itemBuilder: ((context, index) =>
                              jobAssignedContent(index))),
                ),
              ),
              Container(
                color: AppColor().milkWhite,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: jobConfirmList.isEmpty
                      ? const Center(child: Text('No job confirm for today'))
                      : ListView.builder(
                          itemCount: jobConfirmList.length,
                          itemBuilder: ((context, index) =>
                              confirmJobContent(index))),
                ),
              ),
              Container(
                color: AppColor().milkWhite,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                      itemCount: jobLoadList.length,
                      itemBuilder: ((context, index) =>
                          jobLoadsContent(index))),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: palletCategories(),
          ),
        ],
      ),
    );
  }

  moveToConfirmDialogBox(palletActivityId) => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            backgroundColor: Colors.white,
            elevation: 3.0,
            title: const Text(
              'Confirm to accept this assigned job?',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColor().yaleBlue,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  confirmJob(palletActivityId);
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColor().yaleBlue,
                  ),
                ),
              ),
            ],
          );
        },
      );

  moveToLoadDialogBox(palletActivityId) => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            backgroundColor: Colors.white,
            elevation: 3.0,
            title: const Text(
              'Confirm to load this pallet to truck?',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColor().yaleBlue,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  loadJob(palletActivityId);
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColor().yaleBlue,
                  ),
                ),
              ),
            ],
          );
        },
      );

  // Create Signature pop up box
  Future<void> closePalletDialogBox(int index) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
            child: AlertDialog(
              elevation: 3.0,
              backgroundColor: AppColor().milkWhite,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              title: Center(
                child: Text(
                  'Sign To Close Pallet: ${jobAssignedList[index].palletNo}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 280,
                    width: double.maxFinite,
                    child: SfSignaturePad(
                      key: signaturePadKey,
                      minimumStrokeWidth: 1,
                      maximumStrokeWidth: 3,
                      strokeColor: Colors.blue,
                      backgroundColor: Colors.white,
                      onDrawEnd: () {
                        _signature = true;
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _signature == false
                        ? customTextErr(signatureErr)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              actions: <Widget>[
                Column(
                  children: [
                    ListTile(
                      title: Text('Clear Signature',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade500,
                            fontWeight: FontWeight.w600,
                          )),
                      onTap: () {
                        _signature = null;
                        signaturePadKey.currentState!.clear();
                      },
                    ),
                    Divider(
                      thickness: 2.0,
                      indent: 20.0,
                      endIndent: 20.0,
                      height: 0.1,
                      color: Colors.grey.shade300,
                    ),
                    ListTile(
                      title: Text(
                        'Submit Signature',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => validateSiganture(index),
                    ),
                    Divider(
                      thickness: 2.0,
                      indent: 20.0,
                      endIndent: 20.0,
                      height: 0.1,
                      color: Colors.grey.shade300,
                    ),
                    ListTile(
                      title: const Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _signature = null;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //TODO: Amend validation
  validateSiganture(index) {
    if (_signature == null) {
      signatureErr = 'Please sign the pallet before submit.';
      _signature = false;
    }
    print(signatureErr);
  }

  _sendSignature(int index) async {
    Navigator.of(context).pop();

    // Save the signature as a file
    ui.Image signature = await signaturePadKey.currentState!.toImage();

    ByteData? byteData =
        await signature.toByteData(format: ui.ImageByteFormat.png);
    Uint8List signatureBytes = byteData!.buffer.asUint8List();

    //Create temporary directory to store the signature image
    final tempDir = await getTemporaryDirectory();
    File signatureFile =
        File('${tempDir.path}/${jobLoadList[index].palletNo}.jpeg');
    await signatureFile.writeAsBytes(signatureBytes);

    var res = await ApiServices.signature.sendSignature(
        jobLoadList[index].palletActivityId, signatureFile, isAccess);

    if (mounted) {
      if (res.statusCode != HttpStatus.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send signature. Please try again.'),
            backgroundColor: Colors.red.shade300,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully sign the pallet.'),
            backgroundColor: Colors.green.shade300,
            duration: const Duration(seconds: 5),
          ),
        );

        // Call the close pallet api
        closePallet(jobLoadList[index].palletActivityId);
        return;
      }
    }
    setState(() {});
  }
}