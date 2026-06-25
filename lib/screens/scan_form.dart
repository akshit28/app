import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:aap/services/scan_service.dart';
import "package:aap/models/testchamber_model.dart";
import "package:aap/models/scanpayload_model.dart";
import 'package:aap/util/snackbar.dart';
// import 'package:dropdown_search/dropdown_search.dart';
import 'package:aap/screens/bottom_nav.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
// import 'package:aap/models/kitcodedetails_model.dart';
import 'dart:async';
import 'package:aap/services/kit_service.dart';
import 'package:flutter/services.dart';
import 'package:aap/util/debounce.dart';
import 'package:aap/util/dropDown.dart';

class ScanForm extends StatefulWidget {
  // final String patientId;
  const ScanForm({super.key});

  @override
  State<ScanForm> createState() => _ScanFormState();
}

class _ScanFormState extends State<ScanForm> {
  // List<DropdownOption> aks = [];
  // DropdownOption? selectedAks;
  final _formKey = GlobalKey<FormState>();
  final kitCode = TextEditingController();
  final sampleCode = TextEditingController();

  List facility = [];
  DropdownOption? selectedFacility;

  List devices = [];
  DropdownOption? selectedDevice;

  List tests = [];
  DropdownOption? selectedTest;

  bool isShow = false;
  String testType = "";
  String chamberNum = "";
  String concatVal = "";
  List<TestChamber> testChamberNum = [];
  List protocolList = [];
  late List<TextEditingController> controllers;
  late List<Map<String, dynamic>> protocolValues;
  bool kitValidated = false;
  bool isLoading = false;

  bool isRequesting = false;
  String selectedTestGroupId = '';
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final _debouncer = Debouncer(milliseconds: 500);
  late String patientName = '';

  @override
  void initState() {
    super.initState();
    populateFacilities();
    // resetDropdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      patientName = args?['patientName'] ?? '';  // Your state update logic here
    });
  });
    
  }

  void handleFacilityonchange(newValue) {
    setState(() {
      selectedFacility = newValue;
    });

    populateDevices(selectedFacility!.value);
  }

  void handleDeviceonchange(newValue) {
    setState(() {
      selectedDevice = newValue;
    });

    populateTestgroup(selectedFacility!.value, selectedDevice!.value);
  }

  void handleTestonchange(newValue) {
    setState(() {
      selectedTest = newValue;
    });

    populateTestdetails(
        selectedDevice!.displayText.split(' ')[0], selectedTest!.value);
  }

  populateFacilities() async {
    
    var scan = ScanService();
    final facilityList = await scan.getFacility();
    final facilities = facilityList.data.facilities;
    facility = [];
    facility = facilities.map((item) {
      return DropdownOption(
        value: item.id,
        displayText: item.name,
      );
    }).toList();
    if (facilities.length == 1) {
      selectedFacility = facility[0];
      populateDevices(facilities[0].id);
    }
    setState(() {});
  }

  populateDevices(String selectedFac) async {
    var scan = ScanService();
    // List filteredDevice;
    final data = await scan.getDevices(selectedFac);
    if (!data.success || data.data == null) {
      CustomSnackBar(seconds: 2, text: data.error, type: 'error').show(context);
      return;
    }

    final deviceList = data.data.devices;
    final devicesFiltered = deviceList.where((item) {
      return item.isOnline == "ONLINE";
    }).toList();
    devices = [];
    devices = devicesFiltered.map((item) {
      return DropdownOption(
        value: item.masterDeviceId,
        displayText: "${item.deviceName} ${item.status}",
      );
    }).toList();

    if (devices.length == 1) {
      selectedDevice = devices[0];
      populateTestgroup(selectedFacility!.value, selectedDevice!.value);
    }
    setState(() {});
  }

  populateTestgroup(String facilityId, String masterDeviceId) async {
    var scan = ScanService();
    final data = await scan.getTestGroup(facilityId, masterDeviceId);

    var testGroup = data.data.testGroups;
    tests = [];
    tests = testGroup.map((item) {
      return DropdownOption(
        value: item.testGroupId,
        displayText: item.testGroupName,
      );
    }).toList();

    if (selectedTestGroupId.isNotEmpty) {
      int index =
          tests.indexWhere((element) => element.value == selectedTestGroupId);
      if (index != -1) {
        selectedTest = tests[index];
        populateTestdetails(
            selectedDevice!.displayText.split(' ')[0], selectedTestGroupId);
      }
      selectedTestGroupId = '';
    }

    setState(() {});
  }

  populateTestdetails(String deviceSerial, String testGroupId) async {
    isRequesting = true;
    var scan = ScanService();
    // var openFieldCounter = 0;

    final data = await scan.getTestList(deviceSerial, testGroupId);

    var testDetail = data.data.protocols;
    if (testChamberNum.isNotEmpty) {
      testChamberNum.clear();
    }

    if (testDetail.isNotEmpty) {
      // testType = selectedTest!.displayText;
      // chamberNum = testDetail[0].chamberNumber.toString();
      concatVal = "";
      protocolList = testDetail;

      for (var item in testDetail) {
        concatVal += '${item.protocolName}: ${item.chamberNumber}\n';
        if (!item.isMicroscopy) {
          testChamberNum.add(TestChamber(
              protocolId: item.protocolId, chamberNumber: item.chamberNumber.toString()));
        }
      }

      isShow = true;
    } else {
      isShow = false;
    }
    isRequesting = false;
    setState(() {});
  }

  onUpdate(String protocolId, String value) {
    testChamberNum.add(
        TestChamber(protocolId: protocolId, chamberNumber: value));
  }

  validateKitcode(BuildContext context, String val) async {
    var scan = ScanService();

    if (val.length >= 6) {
      if (selectedFacility == null || selectedTest == null) {
        const CustomSnackBar(
                seconds: 2, text: 'Please select Facility/ test', type: 'error')
            .show(context);
        return;
      }

      var payload = {
        "facilityId": selectedFacility!.value,
        "testGroupId": selectedTest!.value,
        "kitCode": val.toString().toUpperCase()
      };

      final data = await scan.validateKit(payload);
      if (data == true) {
        kitValidated = true;
        if (mounted) {
          const CustomSnackBar(
                  seconds: 1, text: 'Kit code valid', type: 'success')
              .show(context);
        }
      } else {
        if (mounted) {
          CustomSnackBar(
                  seconds: 1,
                  text:
                      '${val.toString().toUpperCase()} is not a valid Kit code',
                  type: 'error')
              .show(context);
        }
      }
      return kitValidated;
    }
  }

  // firePrint() {
  //   print("Button pressed-----");
  // }

  fireNewScan(BuildContext context) async {
    setState(() {
      isRequesting = true;
    });
    var scan = ScanService();
    // Object? patientId = ModalRoute.of(context)!.settings.arguments;

    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // print(args!['patientId']);
    // print(args!['patientName']);


    if (!_formKey.currentState!.validate()) {
      setState(() {
        isRequesting = false;
      });
      return;
    }
    if (!kitValidated && !kitCode.text.isEmpty) {
      var data =
          await validateKitcode(context, kitCode.text.toString().toUpperCase());
      if (!data) {
        setState(() {
          isRequesting = false;
        });
        if (mounted) {
          const CustomSnackBar(
                  seconds: 1, text: 'Enter a valid Kit code', type: 'error')
              .show(context);
          return;
        }
      }
    }

    //TODO: Patient ID null check

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      ScanPayload payload = ScanPayload(
          facilityId: selectedFacility!.value,
          deviceCode: selectedDevice!.displayText.split(" ")[0],
          testGroupId: selectedTest!.value,
          patientId: args!['patientId'].toString(),
          kitCode: "",
          testChamberNumber: testChamberToJson(testChamberNum),
          externalPatientCode: "",
          externalSampleCode: sampleCode.text.toString(),
          batchType: "TEST_SAMPLE");
          // print(payload.toString());

      final data = await scan.setScanQueue(payload);

      if (data.success) {
        _formKey.currentState!.reset();
        selectedDevice = null;
        selectedFacility = null;
        selectedTest = null;
        kitCode.clear();
        sampleCode.clear();
        kitValidated = false;

        if (mounted) {
          const CustomSnackBar(
                  seconds: 1, text: 'New Scan is initiated.', type: 'success')
              .show(context);
        }
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNav(routeIndex: 2),
            ),
          );
        });
      } else {
        if (mounted) {
          CustomSnackBar(seconds: 2, text: data.error, type: 'error')
              .show(context);
        }
      }
      isRequesting = false;
      isLoading = false;
      setState(() {});
    }
  }

  fetchKitDetails(
      BuildContext context, String type, String fetchedKitCode) async {
    var kit = KitService();
    final data = await kit.fetchKitDetails(type, fetchedKitCode);

    if (data.success) {
      // final kitDetails = KitCodeDetailsModel.fromJson(json.decode(data));
      kitCode.text = data.data.rows.kitCode;
      if (data.data.rows.facilities.length == 1 && facility.isEmpty) {
        facility.add(DropdownOption(
          displayText: data.data.rows.facilities[0]["name"],
          value: data.data.rows.facilities[0]["id"],
        ));
        selectedFacility = facility[0];
      }

      if (data.data.rows.devices.length == 1 && devices.isEmpty) {
        devices.add(DropdownOption(
          displayText: data.data.rows.devices[0]["serial"],
          value: data.data.rows.devices[0]["id"],
        ));
        selectedDevice = devices[0];
      }

      if (data.data.rows.testGroups.length == 1) {
        if (tests.isNotEmpty) {
          int index = tests.indexWhere(
              (element) => element.value == data.data.rows.testGroups[0]["id"]);
          if (index != -1) {
            selectedTest = tests[index];
            populateTestdetails(
                selectedDevice!.displayText.split(' ')[0], selectedTest!.value);
          }
        } else {
          tests.add(DropdownOption(
              displayText: data.data.rows.testGroups[0]["name"],
              value: data.data.rows.testGroups[0]["id"]));
          selectedTestGroupId = data.data.rows.testGroups[0]["id"];
          selectedTest = tests[0];
        }
      } else if (data.data.rows.testGroups.length > 1) {
        var testGroup = data.data.rows.testGroups;
        tests.clear();
        tests = testGroup.map((item) {
          return DropdownOption(
            value: item['id'],
            displayText: item['name'],
          );
        }).toList();
      }

      if (data.data.rows.facilities.length == 1 &&
          data.data.rows.devices.length != 1 &&
          devices.isEmpty) {
        populateDevices(data.data.rows.facilities[0]["id"]);
      } else if (data.data.rows.facilities.length == 1 &&
          data.data.rows.devices.length == 1 &&
          tests.isEmpty) {
        populateTestgroup(data.data.rows.facilities[0]["id"],
            data.data.rows.devices[0]["id"]);
      } else if ((data.data.rows.facilities.length == 1 &&
          data.data.rows.devices.length == 1 &&
          data.data.rows.testGroups.length == 1)) {
        populateTestdetails(data.data.rows.devices[0]["serial"],
            data.data.rows.testGroups[0]["id"]);
      }

      setState(() {});
    } else {
      if (mounted) {
        const CustomSnackBar(
                seconds: 1, text: 'Kit Code record not found', type: 'error')
            .show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.blue,
          title: const Text("Scan Form"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // minimumSize: Size(width, height)
                            ),
                        onPressed: () {
                          _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                              context: context,
                              onCode: (code) {
                                final rawString = code!.replaceAll("'", '"');
                                final kitCode = jsonDecode(rawString);
                                fetchKitDetails(
                                    context, kitCode['type'], kitCode['code']);
                              });
                        },
                        child: const Text('Scan Kit QR Code'),
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Text("OR Enter Details"),
                      Expanded(child: Divider()),
                    ],
                  ),
                  Visibility(
                    visible: patientName.isNotEmpty ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                      child: RichText(
                              text: TextSpan(
                                  text: 'Patient Name: ',
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: patientName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  ]),
                            ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(15),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey),
                        )),
                        hint: const Text("Select facility"),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: facility
                            .map((item) => DropdownMenuItem<DropdownOption>(
                                value: item, child: Text(item.displayText)))
                            .toList(),
                        onChanged: handleFacilityonchange,
                        value: selectedFacility,
                        validator: (value) =>
                            value == null ? 'Please select a facility' : null,
                      )),
                  Padding(
                      padding: const EdgeInsets.all(15),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey),
                        )),
                        hint: const Text("Select Device"),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: devices
                            .map((item) => DropdownMenuItem<DropdownOption>(
                                value: item, child: Text(item.displayText)))
                            .toList(),
                        onChanged: handleDeviceonchange,
                        value: selectedDevice,
                        validator: (value) =>
                            value == null ? 'Please select a device' : null,
                      )),
                  Padding(
                      padding: const EdgeInsets.all(15),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey),
                        )),
                        hint: const Text("Select Test"),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: tests
                            .map((item) => DropdownMenuItem<DropdownOption>(
                                value: item, child: Text(item.displayText)))
                            .toList(),
                        onChanged: handleTestonchange,
                        value: selectedTest,
                        validator: (value) =>
                            value == null ? 'Please select a test' : null,
                      )),
                  // Padding(
                  //   padding: const EdgeInsets.all(15),
                  //   child: TextFormField(
                  //     controller: kitCode,
                  //     textCapitalization: TextCapitalization.characters,
                  //     decoration: const InputDecoration(
                  //         border: OutlineInputBorder(),
                  //         labelText: 'Kit Code',
                  //         hintText: 'Kit Code'),
                  //     // validator: (value) {
                  //     //   if (value == null ||
                  //     //       value.isEmpty ||
                  //     //       value.length != 6) {
                  //     //     return 'Please enter valid kit code';
                  //     //   }
                  //     //   return null;
                  //     // },
                  //     // onChanged: (input) => validateKitcode(context, input),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: sampleCode,
                      // keyboardType: TextInputType.,
                      inputFormatters: [AlphaNumericTextInputFormatter()],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Sample Code',
                          hintText: 'Sample Code'),
                    ),
                  ),
                  Visibility(
                      visible: isShow,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Chamber / Vesssel Details:",
                                      style: TextStyle(fontSize: 20))),
                              ListView.builder(
                                  key: Key(DateTime.now().toString()),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: protocolList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 10),
                                        child: TextFormField(
                                          readOnly:
                                              protocolList[index].isMicroscopy
                                                  ? false
                                                  : true,
                                          enabled:
                                              protocolList[index].isMicroscopy
                                                  ? true
                                                  : false,
                                          initialValue: protocolList[index]
                                              .chamberNumber
                                              .toString(),
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText: protocolList[index]
                                                .protocolName,
                                          ),
                                          onChanged: (val) {
                                            onUpdate(
                                                protocolList[index].protocolId,
                                                val);
                                          },
                                        ));
                                  })
                            ],
                          ))),
                  isLoading
                      ? const Center(
                        child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(),
                          ),
                      )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                          child: Center(
                            child: Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextButton(
                                // onPressed: () => isRequesting ? null : fireNewScan(context),
                                onPressed: () => isRequesting
                                    ? null
                                    : _debouncer.run(() {
                                        // firePrint();
                                        fireNewScan(context);
                                      }),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontFamily: "Cairo",
                                      height: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )));
  }
}

class AlphaNumericTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final regExp = RegExp(r'^[a-zA-Z0-9]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
