import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aap/util/dropDown.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/util/snackbar.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/defaulttg_model.dart';

class DefaultTestGroup extends StatefulWidget {
  const DefaultTestGroup({super.key});

  @override
  State<DefaultTestGroup> createState() => _DefaultTestGroupState();
}

class _DefaultTestGroupState extends State<DefaultTestGroup> {
  final _formKey = GlobalKey<FormState>();
  List facility = [];
  DropdownOption? selectedFacility;

  List devices = [];
  DropdownOption? selectedDevice;

  List tests = [];
  DropdownOption? selectedTest;
  var sharedIns = SharedPref();
  late List deviceList;
  bool isLoading = false;
  bool isRequesting = false;
  List localdeviceMap = [];

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
    localDeviceMapping();
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
    if(mounted){
      if (!data.success || data.data == null) {
       CustomSnackBar(seconds: 2, text: data.error, type: 'error').show(context);
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

  setDefaultTestGroup(BuildContext context, String deviceName, String tgId) async {
    
    setState(() {
      isLoading = true;
      isRequesting = true;
    });
    // var scan = ScanService();
    // DefaultTG defaultTestGroupObj;
    print("setDefaultTestGroup called----");
    print(deviceName);
    print(tgId);

    List device = deviceList.where((element) {return element.deviceName == deviceName;}).toList();
    // print(deviceId);
    var resp = await ScanService().setDefaultTestGroup(device[0].deviceId, tgId);

    if (resp == true) {
      DefaultTG defaultTestGroupObj = DefaultTG(tgName: selectedTest!.displayText, tgId: tgId, deviceName: deviceName, facilityId: selectedFacility!.value);
      saveObjectToPrefs(defaultTestGroupObj);
    }else{
      
    }

    setState(() {
      isLoading = false;
      isRequesting = false;
    });

  }

  // Function to save the object to SharedPreferences
  Future<void> saveObjectToPrefs(DefaultTG defaultTestGroup) async {
    // List<String> recTg;
    // var sharedIns = SharedPref();
    // SharedPref prefs = await SharedPref();
    // String jsonString = jsonEncode(object.toJson());
    List<DefaultTG> defaultTestGroupList = [];
    DefaultTG dtG = DefaultTG(tgName: "", tgId: "", deviceName: "", facilityId: "");

    List fetchedTG = await sharedIns.getValueAsStringList('defaultTestGroup');

    List fetchedList = fetchedTG!.map((item) => DefaultTG.fromJson(jsonDecode(item))).toList();

    print(fetchedList);
    if(fetchedList.isNotEmpty){
      
      // bool deviceExists = fetchedList.firstWhere((element) => element.deviceName == defaultTestGroup.deviceName);
      DefaultTG deviceExists = fetchedList.firstWhere(
      (obj) => obj.deviceName == defaultTestGroup.deviceName,
        orElse: () => dtG,
      ) ?? dtG;
      if(deviceExists != null && deviceExists.tgId.isNotEmpty){
      // deviceExist
        deviceExists.tgName = defaultTestGroup.tgName;
        deviceExists.tgId = defaultTestGroup.tgId;

        // Print the updated list (optional)
        fetchedList.forEach((obj) {
          print('Device Name: ${obj.deviceName}, TG Name: ${obj.tgName}, Facility ID: ${obj.facilityId}');
        });
        
      }else{
        fetchedList.add(defaultTestGroup);
      }
    }else{
      fetchedList.add(defaultTestGroup);
    }
    
    List<String> encodedList = fetchedList.map((item) => jsonEncode(item.toJson())).toList();
    await sharedIns.saveValueAsStringList('defaultTestGroup', encodedList);
    localDeviceMapping();
  }

  localDeviceMapping() async{
    List fetchedTG = await sharedIns.getValueAsStringList('defaultTestGroup');
    List fetchedList = fetchedTG!.map((item) => DefaultTG.fromJson(jsonDecode(item))).toList();

    if(fetchedList.isNotEmpty){
      localdeviceMap = fetchedList;
    }else{

    }

    setState(() {
      
    });
  }

  // Future getObjectFromPref() async{
  //   final userToken = await sharedIns.getValueFromSharedPreferences("defaultTgSet");
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Default Test Group"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Visibility(
                visible: localdeviceMap.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       Container(
                      // color: Colors.red,
                        child: const Text("Device Mapping:", style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black))),
                      Container(
                        height: localdeviceMap.length * 30,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: localdeviceMap.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Text('${index+1}. ${localdeviceMap[index].deviceName} - ${localdeviceMap[index].tgName}'),
                            );
                          },),
                      ),
                      const Row(
                      children: [
                        Expanded(child: Divider()),
                        Text("OR"),
                        Expanded(child: Divider()),
                      ],
                    ),
                    ],
                  ),
                )
                ),
              Visibility(
              visible: facility.length > 1 ? true : false,
              child: Padding(
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
            ),
            Visibility(
              visible: devices.length > 1 ? true : false,
              child: Padding(
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
            ),
            Padding(
                padding: const EdgeInsets.all(15),
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
                isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                      child: Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () =>
                              isRequesting ? null : setDefaultTestGroup(context, selectedDevice!.displayText, selectedTest!.value),
                          child: const Text(
                            'Set Test Group',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: "Cairo",
                                height: 1.5),
                          ),
                        ),
                      ),
                    ),
            ],
          )
          ),
      ),
    );
  }
}