import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:aap/services/protocol_service.dart";
import "package:aap/models/testscanlist_model.dart" as TestScan;
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import 'package:aap/util/snackbar.dart';
import "package:aap/services/mqtt_manager.dart";
import "package:url_launcher/url_launcher.dart";
import "package:provider/provider.dart";
import "package:aap/providers/protocol_provider.dart";
import 'package:aap/util/confirmDialog.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/services/report_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:aap/util/timer.dart';
// import 'package:aap/util/lifecycle_event_handler.dart';

import 'package:fbroadcast/fbroadcast.dart';
import 'dart:convert';
import 'package:aap/util/debounce.dart';
import 'package:aap/util/filterDialog.dart';

class Protocol extends StatefulWidget {
  const Protocol({super.key});

  @override
  State<Protocol> createState() => _ProtocolState();
}

class _ProtocolState extends State<Protocol> with WidgetsBindingObserver {
  MqttManager? mqttManager;
  // late LifecycleEventHandler _observer;
  ScrollController scrollController = ScrollController();
  late TestScan.TestScanList scanList;
  late var protocolPvdr = context.read<ProtocolProvider>();

  List scans = [];
  List item = [];
  List deviceList = [];
  int dataLength = 0;
  bool loading = false;
  int perPage = 20;
  int currentPage = 1;
  int totalPage = 1;
  int nextPage = 1;
  late DateTime apiCallTimestamp;
  int totalCount = 0;
  bool kitSubscribed = false;
  // int pushSampleIndex = 0;
  String pushSampleId = '';
  DateTime lastRefreshedTime = DateTime.now();
  bool isRefreshCall = false;
  bool deviceSubscribed = false;
  List selectedSampleId = [];
  List<bool> checkboxValues = [];
  final _debouncer = Debouncer(milliseconds: 500);
  bool timerOn = false;
  late int countDownTimerVal;
  List devices = [];
  bool filterApplied = false;
  List devicesList = [];
  // late Timer _timer;

  @override
  void initState() {
    fetchScanList(call: 'init');
    connectSocket();
    initializeDateFormatting();
    // getDeviceList();
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addObserver(this);
    FBroadcast.instance().register("scan_update", (value, callback) {
      // print("pushSampleId***** $pushSampleId");
      getPushSamplePosition(value);
    }, context: this);
    //backgroundListner();

    super.initState();
  }

  // backgroundListner() async {
  // _observer = LifecycleEventHandler(resumeCallBack: fetchScanList('init'));
  // WidgetsBinding.instance.addObserver(_observer);
  // }

  @override
  void dispose() {
    scrollController.dispose();
    mqttManager?.disconnect();
    item.clear();
    scans.clear();
    FBroadcast.instance().unregister('scan_update');
    FBroadcast.instance().clear('scan_update');
    // WidgetsBinding.instance.removeObserver(_observer);
    WidgetsBinding.instance.removeObserver(this);
    unsubscribeList(deviceList);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       print("RESUMED");
  //       fetchScanList('init');
  //       break;
  //     case AppLifecycleState.inactive:
  //       print("INACTIVE");
  //       break;
  //     case AppLifecycleState.paused:
  //       print("PAUSED");
  //       break;
  //     case AppLifecycleState.detached:
  //       print("DETACHED");
  //       break;
  //   }
  // }

  void scrollListener() {
    if (!loading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      setState(() {
        loading = true;
      });
      fetchScanList(call: 'loadmore');
    }
  }

  fetchScanList(
      {required String call,
      String device = "",
      String startDate = "",
      String endDate = "",
      String mobNum = ""}) async {
    var payload = {};
    loading = true;
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    print("fetchScanList with param $call");
    apiCallTimestamp = now;

    if (call == 'init') {
      item.clear();
      scans.clear();
      payload['deviceId'] = "";
      payload["endDate"] = now.toIso8601String().toString();
      payload["mobileNumber"] = "";
      payload["pageNum"] = 1;
      payload["rowCount"] = 20;
      payload["startDate"] = yesterday.toIso8601String().toString();
      nextPage = 1;
      currentPage = 1;
    } else if (call == "loadmore") {
      isRefreshCall = true;
      currentPage = currentPage + 1;
      payload['deviceId'] = "";
      payload["endDate"] = now.toIso8601String().toString();
      payload["mobileNumber"] = "";
      payload["pageNum"] = nextPage;
      payload["rowCount"] = 20;
      payload["startDate"] = yesterday.toIso8601String().toString();
    } else if (call == "filter") {
      item.clear();
      scans.clear();
      payload['deviceId'] = device;
      payload["mobileNumber"] = mobNum;
      payload["pageNum"] = 1;
      payload["startDate"] = startDate;
      payload["endDate"] = endDate;
      payload["rowCount"] = 20;
      nextPage = 1;
      currentPage = 1;
      filterApplied = true;
    }

    if (nextPage > totalPage) {
      const CustomSnackBar(seconds: 2, text: 'End of records.', type: '')
          .show(context);
      loading = false;
      return null;
    }

    var response = await protocolPvdr.getProtocolList(payload);

    if (response.success) {
      scanList = response;
      // if(call == "filter"){

      //   scans.addAll(scanList.data.rows);
      // }else{
      scans.addAll(scanList.data.rows);
      // }

      checkboxValues
          .addAll(List.generate(scanList.data.rows.length, (_) => false));

      dataLength = scanList.data.rowCount;
      totalPage = (scanList.data.rowCount / perPage).ceil();
      ++nextPage;

      loading = false;
      setState(() {});
      // subscribeList();

      var pushVal = FBroadcast.value('scan_update');
      // print("scan_update *************** $pushSampleId");
      if (pushVal != null && pushVal.isNotEmpty && !isRefreshCall) {
        getPushSamplePosition(pushVal);
        // FBroadcast.instance().clear('scan_update');
      }

      if (call == 'init') {
        getDeviceList();
      }

      isRefreshCall = false;
    } else {
      if (mounted) {
        const CustomSnackBar(seconds: 4, text: 'No Record found.', type: '')
            .show(context);
      }
      loading = false;
      setState(() {});
    }
    // scanList = await ProtocolService().fetchTestScans(payload);
  }

  updateScanList(String sampleId) async {
    print("updateScanList called $sampleId");
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    var payload = {};
    payload['deviceId'] = "";
    payload["mobileNumber"] = "";
    payload["sampleId"] = sampleId.toString();
    payload["endDate"] = "";
    payload["pageNum"] = 1;
    payload["rowCount"] = 1;
    payload["startDate"] = "";

    protocolPvdr.updateProtocols(payload);
  }

  Future<void> pullRefresh() async {
    if (loading) return;
    isRefreshCall = true;
    fetchScanList(call: 'init');
    const CustomSnackBar(seconds: 4, text: 'Refreshing...', type: '')
        .show(context);
  }

  getDeviceList() async {
    var scan = ScanService();

    final data = await scan.getDevices("");
    // var deviceList = data.data.devices;
    devices = data.data.devices.where((item) {
      // deviceList.add(item.deviceName);
      return item.isOnline == "ONLINE";
    }).toList();

    for (var element in devices) {
      deviceList.add(element.deviceName);
    }
    devicesList = data.data.devices;
    subscribeList();
    setState(() {});
  }

  connectSocket() async {
    mqttManager = MqttManager(
        Uri.parse('wss://mqtt.tangentup.com:9001').toString(), 8883);

    await mqttManager?.connect();
    if (!kitSubscribed) {
      subscribeList();
    }
  }

  subscribeList() {
    if (kitSubscribed) return;

    for (var element in deviceList) {
      if (mqttManager!.isConnected) {
        mqttManager?.subscribe("devices/update/$element");
        kitSubscribed = true;
      }
    }
    recievedMessage();
  }

  unsubscribeList(List param) {
    for (var element in param) {
      if (mqttManager!.isConnected) {
        mqttManager?.unsubscribe("devices/update/$element");
      }
    }
    deviceList.clear();
  }

  void getPushSamplePosition(String sampleId) {
    if (sampleId.isEmpty) return;
    print("getPushSamplePosition called $sampleId");
    int index =
        scans.indexWhere((element) => element.internalSampleId == sampleId);
    print("getPushSamplePosition index $index");

    if (index != -1) {
      scrollToIndex(index);
    }
    // else{
    //   fetchScanList('init');
    // }

    // pushSampleId = '';
  }

  // Scroll to the item at a specific index
  void scrollToIndex(int index) {
    scrollController.animateTo(
      index * 200,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
    // pushSampleId = '';
  }

  recievedMessage() {
    var messageList = mqttManager!.messageStreamController.stream;
    messageList.listen((event) {
      // updateScanList(event);
      print("recieved Message*******");
      // print(json.decode(event));
      if (!filterApplied) {
        protocolPvdr.updateProtocols(event);
      }
    });
  }

  cancelTest(BuildContext context, String internalId) async {
    var resp = await ProtocolService().cancelScan(internalId);

    if (resp == true) {
      if (mounted) {
        const CustomSnackBar(
                seconds: 2, text: 'Scan cancelled.', type: 'success')
            .show(context);
      }
    } else {
      if (mounted) {
        const CustomSnackBar(
                seconds: 2,
                text: 'Error occured while cancelling scan.',
                type: 'error')
            .show(context);
      }
    }
  }

  continueTest(BuildContext context, String internalId) async {
    var resp = await ProtocolService().continueScan(internalId);
    await protocolPvdr.updateProtocolAction(internalId);
    // await Provider.of<ProtocolProvider>(context, listen: false).updateProtocolAction(internalId);
    if (resp == true) {
      // protocolPvdr.removeInstruction(internalId.toString());
      if (mounted) {
        const CustomSnackBar(
                seconds: 2, text: 'Scan continue.', type: 'success')
            .show(context);
      }
    } else {
      protocolPvdr.addContinueButton(internalId);
      if (mounted) {
        const CustomSnackBar(seconds: 2, text: 'Error occured.', type: 'error')
            .show(context);
      }
    }
  }

  openReport(String url) async {
    final Uri link = Uri.parse(url);
    if (!await launchUrl(link)) {
      throw Exception('Could not launch $url');
    }
  }

  openReportDialog(
      BuildContext context, String consolidatedReport, String report) async {
    String title = "Report";
    String content = "Open Report.";

    continueCallBack() =>
        {Navigator.of(context).pop(), openReport(consolidatedReport)};

    cancelCallBack() => {Navigator.of(context).pop(), openReport(report)};

    ConfirmBox alert = ConfirmBox(
        title: title,
        content: content,
        continueCallBack: continueCallBack,
        cancelCallBack: cancelCallBack,
        button1Text: 'Combined Report',
        button2Text: 'Report');

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  // shareReport(String url) async {
  //   await Share.share(url, subject: "Report");
  // }

  showCancelDialog(BuildContext context, String sampleId) {
    String title = "Cancel";
    String content = "Are you sure you want to cancel test $sampleId.";
    continueCallBack() =>
        {Navigator.of(context).pop(), cancelTest(context, sampleId)};

    cancelCallBack() => {
          Navigator.of(context).pop(),
        };
    ConfirmBox alert = ConfirmBox(
        title: title,
        content: content,
        continueCallBack: continueCallBack,
        cancelCallBack: cancelCallBack);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showContinueDialog(BuildContext context, String sampleId) {
    String title = "Continue";
    String content = "Are you sure you want to Continue test $sampleId.";
    continueCallBack() =>
        {Navigator.of(context).pop(), continueTest(context, sampleId)};

    cancelCallBack() => {
          Navigator.of(context).pop(),
        };
    ConfirmBox alert = ConfirmBox(
        title: title,
        content: content,
        continueCallBack: continueCallBack,
        cancelCallBack: cancelCallBack);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  cardBorderColor(String status) {
    switch (status) {
      case "CANCELLED":
      case "FAILED":
        return Colors.red.shade900;
      case "REPORT_GENERATED":
      case "REPORT_READY":
        return Colors.green.shade800;
      case "PROCESSING":
        return Colors.greenAccent.shade700;
      case "CREATED":
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  newScanReq(String patientId, String patientName) {
    Navigator.pushNamed(context, '/scan_form',
        arguments: {'patientId': patientId, 'patientName': patientName});
  }

  cardMenuItemClick(BuildContext context, String item) {
    switch (item) {
      case 'combine_report':
        callCombineReports(context);
        break;
      case 'filter':
        openFilterDialog(context);
        break;
      // default:
    }
  }

  bool anyChecked() {
    // return selectedSampleId.length > 1 && checkboxValues[index];
    return selectedSampleId.length > 1;
  }

  enableCompoundReport(bool checkVal, String sampleId) async {
    if (checkVal && !selectedSampleId.contains(sampleId)) {
      selectedSampleId.add(sampleId);
    } else if (!checkVal && selectedSampleId.contains(sampleId)) {
      selectedSampleId.remove(sampleId);
    }
  }

  callCombineReports(BuildContext context) async {
    if (!anyChecked()) {
      const CustomSnackBar(
              seconds: 3,
              text: 'Select atleast 2 scans of same patient to combine report.',
              type: 'error')
          .show(context);
    } else {
      var resp = await ReportService().consolidateReports(selectedSampleId);
      if (resp == true) {
        if (mounted) {
          getPushSamplePosition(selectedSampleId[0]);
          const CustomSnackBar(
                  seconds: 1,
                  text: 'Combined report generated.',
                  type: 'success')
              .show(context);
        }
        // fetchScanList('init');
      } else {
        if (mounted) {
          CustomSnackBar(seconds: 2, text: resp.error, type: 'error')
              .show(context);
        }
      }

      checkboxValues = checkboxValues.map<bool>((v) => false).toList();
      selectedSampleId.clear();
    }

    setState(() {});
  }

  openFilterDialog(BuildContext context) {
    continueCallBack(
            String device, String startDate, String endDate, String mobNum) =>
        {
          Navigator.of(context).pop(),
          if (device.isEmpty &&
              startDate.isEmpty &&
              endDate.isEmpty &&
              mobNum.isEmpty)
            {}
          else
            {
              fetchScanList(
                  call: "filter",
                  device: device,
                  startDate: startDate,
                  endDate: endDate,
                  mobNum: mobNum)
            }
        };

    FilterDialog filter =
        FilterDialog(devices: devicesList, continueCallBack: continueCallBack);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return filter;
        });
  }

  applyFilter() {}

  void _showPopupMenu(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;

    final RelativeRect position = RelativeRect.fromLTRB(
      screenSize.width - 30.0,
      screenSize.height - kToolbarHeight - kBottomNavigationBarHeight - 100,
      screenSize.width - 16.0,
      screenSize.height - kToolbarHeight - kBottomNavigationBarHeight,
    );

    final result = await showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'filter',
          child:
              ListTile(leading: Icon(Icons.filter_alt), title: Text("Filter")),
        ),
        PopupMenuItem(
            value: 'combine_report',
            child: ListTile(
                leading: const Icon(Icons.library_add),
                title: Text("Combine Report (${selectedSampleId.length})")),
            onTap: () {
              cardMenuItemClick(context, 'combine_report');
            }),
      ],
      elevation: 8.0,
    );

    if (mounted && result == 'filter') {
      openFilterDialog(context);
    }
  }

  void playRinger(bool ringerFlag) {
    print("play ringer called**********************$ringerFlag");
    if (ringerFlag) {
      FlutterRingtonePlayer().play(
          fromAsset: "assets/sounds/pause.mp3",
          ios: IosSounds.glass,
          looping: false, // Android only - API >= 28
          volume: 1, // Android only - API >= 28
          asAlarm: false);
    } else {
      FlutterRingtonePlayer().stop();
    }
  }

  void stopTimer() {
    print("stopTimer called***");
    timerOn = false;
  }

  void clearFilter() {
    filterApplied = false;
    fetchScanList(call: 'init');
  }

  bool newScanflag(String sampleStatusCode) {
    switch (sampleStatusCode) {
      case "CANCELLED":
      case "FAILED":
      case "QUEUED_FOR_REPORT":
      case "REPORT_GENERATED":
      case "REPORT_READY":
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    totalCount = context.watch<ProtocolProvider>().totalRows;
    item = context.watch<ProtocolProvider>().protocolList;
    lastRefreshedTime = context.watch<ProtocolProvider>().lastRefreshed;

    showProtocolDetails(BuildContext context, String internalSampleId) {
      final sampleRow = item
          .where((element) => element.internalSampleId == internalSampleId)
          .toList();
      List sampleChildDetail = sampleRow[0].childs;
      List<DataRow> childRows = [];

      sampleChildDetail.forEach((element) {
        childRows.add(DataRow(
          cells: <DataCell>[
            DataCell(Container(
              height: 70,
              alignment: Alignment.centerLeft,
              child: Text(element.protocolName),
            )),
            // DataCell(Center(child: Text(element.chamberNumber.toString()))),
            DataCell(Center(
                child: Text("${element.status}\n${element.statusName ?? ''}"))),
          ],
        ));
      });

      showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black45,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) {
            return Center(
                child: Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: childRows.length > 1 ? 430 : 330,
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                          child: RichText(
                            text: TextSpan(
                                text: 'Device Name: ',
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: sampleRow[0].deviceName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )
                                ]),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                            child: RichText(
                              text: TextSpan(
                                  text: 'Next Step: ',
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: sampleRow[0].nextStepName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  ]),
                            )),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                            child: RichText(
                              text: TextSpan(
                                  text: 'Requested By: ',
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: sampleRow[0].requestedBy,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  ]),
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                          child: RichText(
                            text: TextSpan(
                                text: 'Updated At: ',
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: DateFormat("dd-MM-yy HH:mm:ss")
                                        .format(DateTime.parse(
                                                sampleRow[0].sampleUpdatedAt)
                                            .toLocal()),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )
                                ]),
                          ),
                        ),
                        DataTable(
                          columnSpacing: 0,
                          horizontalMargin: 10,
                          headingRowColor:
                              MaterialStatePropertyAll(Colors.grey.shade300),
                          columns: const <DataColumn>[
                            DataColumn(label: Text('Protocol Name')),
                            // DataColumn(
                            //     label: Center(child: Text('Chamber No.'))),
                            DataColumn(label: Center(child: Text('Status'))),
                          ],
                          rows: childRows,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 40),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ok',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ))),
                        )
                      ],
                    )));
          });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Protocol Dashboard"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: pullRefresh,
        child: Column(
          children: [
            item.isEmpty && loading
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(15, 40, 15, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                            '${scans.length} of $dataLength records.\nLast Updated ${DateFormat("HH:mm:ss").format(DateTime.parse(lastRefreshedTime.toString()).toLocal())}'),
                        // Text(
                        //     'Last Refreshed ${DateFormat("dd-MM-yy HH:mm:ss").format(DateTime.parse(lastRefreshedTime.toString()).toLocal())}'),
                        const Spacer(),
                        Visibility(
                            visible: filterApplied,
                            child: TextButton(
                                onPressed: () {
                                  clearFilter();
                                },
                                child: Text(
                                  "Clear Filter",
                                  style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold),
                                )))
                      ],
                    ),
                  ),
            Expanded(
                child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                scrollListener();
                return false;
              },
              child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: item.length + (loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (loading) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 2,
                        child: const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 7),
                          child: Card(
                            elevation: 1,
                            color: const Color(0XFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1))),
                              // child: Container(
                              // decoration: BoxDecoration(
                              //     border: Border(
                              //       left: BorderSide(color: cardBorderColor(item[index].sampleStatusCode), width: 5),
                              //     ),
                              //   ),

                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Checkbox(
                                              value: checkboxValues[index],
                                              onChanged: (newVal) {
                                                setState(() {
                                                  checkboxValues[index] =
                                                      newVal!;
                                                });
                                                enableCompoundReport(newVal!,
                                                    item[index].sampleId);
                                              }),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                checkboxValues[index] =
                                                    !checkboxValues[index];
                                              });
                                              enableCompoundReport(
                                                  checkboxValues[index],
                                                  item[index].sampleId);
                                            },
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              // textWidthBasis: ,
                                              text: TextSpan(
                                                  text: '',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    // GestureDetector()
                                                    TextSpan(
                                                      text: item[index]
                                                          .internalSampleId,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    item[index].externalSampleId.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 5, 5),
                                            child: RichText(
                                              text: TextSpan(
                                                  text: 'External Sample Id: ',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text: item[index]
                                                          .externalSampleId,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    )
                                                  ]),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 5, 5),
                                      child: RichText(
                                        text: TextSpan(
                                            text: 'Test: ',
                                            style: const TextStyle(
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text: item[index].testGroup,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )
                                            ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 5, 5),
                                      child: RichText(
                                        text: TextSpan(
                                            text: 'Patient Name: ',
                                            style: const TextStyle(
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text: item[index].patientName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )
                                            ]),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 5, 5),
                                        child: Row(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          // verticalDirection: VerticalDirection.down,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Wrap(
                                              spacing: 5.0,
                                              direction: Axis.vertical,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: 'Kit Id: ',
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                          text: item[index]
                                                              .kitCode,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                        )
                                                      ]),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: 'Status: ',
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                          text: item[index]
                                                              .sampleStatus
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: cardBorderColor(
                                                                  item[index]
                                                                      .sampleStatusCode)),
                                                        )
                                                      ]),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: 'Requested At: ',
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                          text: DateFormat(
                                                                  "dd-MM-yy HH:mm:ss")
                                                              .format(DateTime.parse(
                                                                      item[index]
                                                                          .sampleRequestedAt)
                                                                  .toLocal()),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                        )
                                                      ]),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Visibility(
                                                visible:
                                                    (item[index].showTimer &&
                                                            item[index].inSleep)
                                                        ? true
                                                        : false,
                                                child: Wrap(
                                                  alignment: WrapAlignment.end,
                                                  children: [
                                                    CountdownTimerWidget(
                                                      initialTimeInSeconds: item[
                                                                  index]
                                                              .sleepStarted +
                                                          item[index]
                                                              .waitingPeriod,
                                                      internalSampleId:
                                                          item[index]
                                                              .internalSampleId,
                                                    )
                                                  ],
                                                ))
                                          ],
                                        )),
                                    Visibility(
                                        visible: item[index].message != null &&
                                                !item[index].message.isEmpty
                                            ? true
                                            : false,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 5, 5),
                                          child: RichText(
                                            text: TextSpan(
                                                text: 'Message: ',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text: item[index].message,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  )
                                                ]),
                                          ),
                                        )),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              showProtocolDetails(context,
                                                  item[index].internalSampleId);
                                            },
                                            child: const Text('Details'),
                                          ),
                                          const Spacer(),
                                          Wrap(
                                              // runSpacing: 5.0,
                                              runAlignment:
                                                  WrapAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.end,
                                              spacing: 3.0,
                                              alignment: WrapAlignment.end,
                                              direction: Axis.horizontal,
                                              children: [
                                                Visibility(
                                                    visible: (!item[index]
                                                            .reportLink
                                                            .isEmpty ||
                                                        newScanflag(item[index]
                                                            .sampleStatusCode)),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .blue.shade900,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 12,
                                                                horizontal: 25),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0)),
                                                      ),
                                                      child: const Text(
                                                          'New Scan'),
                                                      onPressed: () {
                                                        newScanReq(
                                                            item[index]
                                                                .patientId,
                                                            item[index]
                                                                .patientName);
                                                      },
                                                    )),
                                                Visibility(
                                                    visible: !item[index]
                                                        .reportLink
                                                        .isEmpty,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .blue.shade900,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 12,
                                                                horizontal: 25),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0)),
                                                      ),
                                                      child:
                                                          const Text('Report'),
                                                      onPressed: () {
                                                        if (item[index]
                                                                    .consolidatedReportLink !=
                                                                null &&
                                                            !item[index]
                                                                .consolidatedReportLink
                                                                .isEmpty) {
                                                          openReportDialog(
                                                              context,
                                                              item[index]
                                                                  .consolidatedReportLink,
                                                              item[index]
                                                                  .reportLink);
                                                        } else {
                                                          openReport(item[index]
                                                              .reportLink);
                                                        }
                                                      },
                                                    )),
                                                Visibility(
                                                    visible: item[index]
                                                            .action
                                                            .contains('CANCEL')
                                                        ? true
                                                        : false,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red.shade800,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0)),
                                                      ),
                                                      child:
                                                          const Text('Cancel'),
                                                      onPressed: () {
                                                        showCancelDialog(
                                                            context,
                                                            item[index]
                                                                .internalSampleId);
                                                      },
                                                    )),
                                                Visibility(
                                                    visible: item[index]
                                                            .action
                                                            .contains(
                                                                'CONTINUE')
                                                        ? true
                                                        : false,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .blue.shade900,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0)),
                                                      ),
                                                      child: const Text(
                                                          'Continue'),
                                                      onPressed: () {
                                                        showContinueDialog(
                                                            context,
                                                            item[index]
                                                                .internalSampleId);
                                                      },
                                                    )),
                                              ]),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                        visible: item[index]
                                                    .consolidatedReportLink !=
                                                null &&
                                            !item[index]
                                                .consolidatedReportLink
                                                .isEmpty,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 4, 8, 2),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.done_all,
                                                  color: Colors.green,
                                                  size: 15),
                                              Text(
                                                "Consolidated Report Generated",
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Visibility(
                                        visible:
                                            item[index].instructions.length > 0
                                                ? true
                                                : false,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 5, 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                  // color: Colors.red,
                                                  child: const Text(
                                                      "Instructions:",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.black))),
                                              Container(
                                                  // color: Colors.red,
                                                  height: item[index]
                                                              .instructions
                                                              .length >
                                                          0
                                                      ? (34.0 *
                                                          item[index]
                                                              .instructions
                                                              .length)
                                                      : 50.0,
                                                  child: ListView.builder(
                                                      // scrollDirection: Axis.horizontal,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: item[index]
                                                          .instructions
                                                          .length,
                                                      itemBuilder:
                                                          (context, pointer) {
                                                        return Container(
                                                          child: Text(
                                                              "${item[index].instructions[pointer]["instruction"]["sequence"]}. ${item[index].instructions[pointer]["instruction"]["message"]}",
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black)),
                                                        );
                                                      }))
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              // ),
                            ),
                          ));
                    }
                  }),
            ))
          ],
        ),
      ),
      floatingActionButton: devicesList.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                _showPopupMenu(context);
              },
              tooltip: 'Open Popup Menu',
              child: const Icon(Icons.more_vert),
            )
          : null,
    );
  }
}
