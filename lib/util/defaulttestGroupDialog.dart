import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aap/util/dropDown.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/util/snackbar.dart';
import 'package:aap/providers/shared_pref.dart';

class DefaultTestGroupDialog extends StatefulWidget {
  const DefaultTestGroupDialog({super.key});

  @override
  State<DefaultTestGroupDialog> createState() => _DefaultTestGroupDialogState();
}

class _DefaultTestGroupDialogState extends State<DefaultTestGroupDialog> {
  // String selectedTestGroupId = '';
  List facility = [];
  DropdownOption? selectedFacility;

  List devices = [];
  DropdownOption? selectedDevice;

  List tests = [];
  DropdownOption? selectedTest;
  var sharedIns = SharedPref();
  late List deviceList;

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
  }

  @override
  void initState() {
    super.initState();
    populateFacilities();
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
    if (mounted) {
      if (!data.success || data.data == null) {
        CustomSnackBar(seconds: 2, text: data.error, type: 'error')
            .show(context);
        return;
      }
    }

    deviceList = data.data.devices;
    final devicesFiltered = deviceList.where((item) {
      return item.isOnline == "ONLINE";
    }).toList();
    devices = [];
    devices = devicesFiltered.map((item) {
      return DropdownOption(
        value: item.masterDeviceId,
        displayText: "${item.deviceName}",
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

    // if (selectedTestGroupId.isNotEmpty) {
    // int index =
    //     tests.indexWhere((element) => element.value == selectedTestGroupId);
    // if (index != -1) {
    //   selectedTest = tests[index];
    // }
    // selectedTestGroupId = '';
    // }

    setState(() {});
  }

  setDefaultTestGroup(
      BuildContext context, String deviceName, String tgId) async {
    // var scan = ScanService();
    print("setDefaultTestGroup called----");
    print(deviceName);
    print(tgId);

    List device = deviceList.where((element) {
      return element.deviceName == deviceName;
    }).toList();
    // print(deviceId);
    var resp =
        await ScanService().setDefaultTestGroup(device[0].deviceId, tgId);

    if (resp == true) {
      await sharedIns.saveValueToSharedPreferences('defaultTestGroupId', tgId);
      await sharedIns.saveValueToSharedPreferences(
          'defaultTestGroupName', selectedTest!.displayText);
      // if(mounted){
      Navigator.of(context).pop();
      // }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("Select Test Group"),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: facility.length > 1 && devices.length > 1 ? 230 : 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Visibility(
              visible: facility.length > 1 ? true : false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
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
            ),
            Visibility(
              visible: devices.length > 1 ? true : false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
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
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
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
          ],
        ),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                ),
                child: const Text('Set Test Group'),
                onPressed: () {
                  setDefaultTestGroup(context, selectedDevice!.displayText,
                      selectedTest!.value);
                }),
          ),
        ),
      ],
    );
  }
}
