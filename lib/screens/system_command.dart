import 'package:flutter/material.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/util/snackbar.dart';
import 'package:aap/services/commands_service.dart';

class SystemCommand extends StatefulWidget {
  const SystemCommand({super.key});

  @override
  State<SystemCommand> createState() => _SystemCommandState();
}

class _SystemCommandState extends State<SystemCommand> {
  final _formKey = GlobalKey<FormState>();
  late List facilities;
  bool isLoading = false;
  bool isRequesting = false;

  List facility = [];
  DropdownOption? selectedFacility;

  List deviceModal = [];
  DropdownOption? selectedDeviceModal;

  List devices = [];
  DropdownOption? selectedDevice;

  List commands = [];
  DropdownOption? selectCommands;
  final commandText = TextEditingController();

  late List commandList;

  @override
  void initState() {
    super.initState();
    populateFacilities();
  }

  void handleFacilityonchange(newValue) {
    setState(() {
      // defaultFacility = newValue.value;
      selectedFacility = newValue;
    });
    populateDevices(selectedFacility!.value);
  }

  void handleDeviceModelonchange(newValue) {
    setState(() {
      selectedDeviceModal = newValue;
    });
    populateCommands(selectedDeviceModal!.value);
  }

  void handleDeviceonchange(newValue) {
    setState(() {
      selectedDevice = newValue;
    });

    // populateTestgroup(selectedFacility!.value, selectedDevice!.value);
  }

  void handleCommandonchange(newValue) {
    setState(() {
      commandText.text = newValue.payload;
      selectCommands = newValue;
    });
  }

  populateFacilities() async {
    var scan = ScanService();
    final facilityList = await scan.getFacility();
    facilities = facilityList.data.facilities;
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
      // defaultFacility = facilities[0].id;
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
    final deviceModalData = data.data.masterDevices;
    
    deviceModal = [];
    deviceModal = deviceModalData.map((item) {
      return DropdownOption(
        value: item.masterDeviceId,
        displayText: "${item.deviceName} ${item.deviceModel}",
      );
    }).toList();

    devices = [];
    devices = deviceList.map((item) {
      return DropdownOption(
        value: item.deviceName,
        displayText: "${item.deviceName} ${item.isOnline} ${item.status}",
      );
    }).toList();

    if (devices.length == 1) {
      selectedDevice = devices[0];
      // populateTestgroup(selectedFacility!.value, selectedDevice!.value);
    }
    setState(() {});
  }

  populateCommands(String masterDeviceId) async {
    var command = CommandService();

    final data = await command.fetchCommands(masterDeviceId);

    if (!data.success || data.data == null) {
      CustomSnackBar(seconds: 2, text: data.error, type: 'error').show(context);
      return;
    }

    commandList = data.data.deviceCommands;

    commands = commandList.map((item) {
      return DropdownOption(
          value: item.deviceCommandId,
          displayText: item.deviceCommandName,
          payload: item.deviceCommandPayload);
    }).toList();

    setState(() {});
  }

  fireNewCommand(BuildContext context) async {
    var command = CommandService();
    if (_formKey.currentState!.validate()) {
      var payload = {
        "device_code": selectedDevice!.value,
        "master_device_id": selectedDeviceModal!.value,
        "facility_id": selectedFacility!.value,
        "device_command_id": selectCommands!.value,
        "command_pay_load": commandText.text
      };

      final response = await command.queueNewCommand(payload);

      if (response["success"]) {
        if (mounted) {
          
          const CustomSnackBar(
                  seconds: 2,
                  text: "The Request for new command is initiated.",
                  type: 'success')
              .show(context);
              selectCommands = null;
              selectedDevice = null;
              selectedDeviceModal = null;
              selectedFacility = null;
              commandText.text = "";
        }
      } else {
        if (mounted) {
          const CustomSnackBar(
                  seconds: 2,
                  text: "There is some error. Try Again.",
                  type: 'error')
              .show(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("System Commands"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Visibility(
                  visible: facility.length > 1 ? true : false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
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
                    ),
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
                    hint: const Text("Select Device Model"),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: deviceModal
                        .map((item) => DropdownMenuItem<DropdownOption>(
                            value: item, child: Text(item.displayText)))
                        .toList(),
                    onChanged: handleDeviceModelonchange,
                    value: selectedDeviceModal,
                    validator: (value) =>
                        value == null ? 'Please select a device model' : null,
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
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  )),
                  hint: const Text("Select Command"),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: commands
                      .map((item) => DropdownMenuItem<DropdownOption>(
                          value: item, child: Text(item.displayText)))
                      .toList(),
                  value: selectCommands,
                  onChanged: handleCommandonchange,
                  validator: (value) =>
                      value == null ? 'Please select a command' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                    controller: commandText,
                    minLines: 4,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter command payload',
                        hintText: 'Enter command payload')),
              ),
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
                              isRequesting ? null : fireNewCommand(context),
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
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownOption {
  final String displayText;
  final String value;
  final String payload;

  @override
  int get hashCode => super.hashCode;

  DropdownOption({
    required this.displayText,
    required this.value,
    this.payload = '',
  });
}
