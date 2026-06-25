import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aap/util/dropDown.dart';
import 'package:intl/intl.dart';

class FilterDialog extends StatefulWidget {
  List devices;
  final Function(String, String, String, String) continueCallBack;
  final String? filterDevice;
  final String? filterStartDate;
  final String? filterEndDate;
  final String? filterMobNum;

  FilterDialog(
      {super.key,
      required this.devices,
      required this.continueCallBack,
      this.filterDevice,
      this.filterStartDate,
      this.filterEndDate,
      this.filterMobNum});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  List devices = [];
  DropdownOption? selectedDevice;
  late List deviceList;
  TextEditingController mobNumber = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  DateTime now = DateTime.now();
  late DateTime _startDate;
  DateTime _endDate = DateTime.now();
  String errorMessage = "";
  bool errorFlag = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(now.year, now.month, now.day - 1);
    populateDevices();
  }

  void handleDeviceonchange(newValue) {
    setState(() {
      selectedDevice = newValue;
    });

    // populateTestgroup(selectedFacility!.value, selectedDevice!.value);
  }

  populateDevices() async {
    // var scan = ScanService();
    // // List filteredDevice;
    // final data = await scan.getDevices("");
    // if(mounted){
    //   if (!data.success || data.data == null) {
    //    CustomSnackBar(seconds: 2, text: data.error, type: 'error').show(context);
    //     return;
    //   }
    // }

    deviceList = widget.devices;
    // final devicesFiltered = deviceList.where((item) {
    //   return item.isOnline == "ONLINE";
    // }).toList();
    // devices = [];
    devices = deviceList.map((item) {
      return DropdownOption(
        value: item.deviceId,
        displayText: "${item.deviceName}",
      );
    }).toList();

    setState(() {});
  }

  Future<void> selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
        initialDateRange: DateTimeRange(
          start: _startDate,
          end: _endDate,
        ),
        saveText: "Done",
        confirmText: "Done",
        builder: (context, child) {
          return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Colors.blue, // Adjust primary color
                // accentColor: Colors.blue, // Adjust accent color
                colorScheme: const ColorScheme.light(
                    primary: Colors.blue), // Adjust color scheme
                buttonTheme: const ButtonThemeData(
                    textTheme:
                        ButtonTextTheme.primary), // Adjust button text theme
              ),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400.0,
                      // maxHeight: 500.0
                    ),
                    child: child,
                  )
                ],
              ));

          // return Column(
          //   children: [
          //     ConstrainedBox(
          //       constraints: const BoxConstraints(
          //         maxWidth: 400.0,
          //         maxHeight: 500.0
          //         ),
          //       child: child,
          //     )
          //   ],
          // );
        });

    if (picked != null) {
      String formattedStartDate = DateFormat('dd-MM-yyyy').format(picked.start);
      String formattedEndDate = DateFormat('dd-MM-yyyy').format(picked.end);
      dateinput.text = "$formattedStartDate - $formattedEndDate";
      _startDate = picked.start;
      _endDate = picked.end;

      setState(() {});
      // Navigator.of(context).pop();
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String getLastMomentOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59)
        .toIso8601String()
        .toString();
  }

  void setFilter() {
    String device = selectedDevice?.value ?? '';
    DateTime now = DateTime.now();
    String sDate = _startDate.toIso8601String().toString();
    String eDate = "";
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (isSameDay(now, _endDate)) {
      eDate = now.toIso8601String().toString();
    } else {
      eDate = getLastMomentOfDay(_endDate);
    }

    if (device.isEmpty &&
        mobNumber.text.isEmpty &&
        isSameDay(_startDate, yesterday)) {
      sDate = "";
      eDate = "";
    }

    if (mobNumber.text.length > 0 && mobNumber.text.length < 10) {
      errorMessage = "Enter correct number";
      errorFlag = true;
      setState(() {});
      return;
    } else {
      errorFlag = false;
      widget.continueCallBack(device, sDate, eDate, mobNumber.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("Select Filters", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 280,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
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
                  // validator: (value) =>
                  //     value == null ? 'Please select a device' : null,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: TextFormField(
                readOnly: true,
                controller: dateinput,
                decoration: InputDecoration(
                    labelText: 'Select Date Range',
                    hintText: 'Select Date Range',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    )),
                onTap: () {
                  selectDateRange(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: TextFormField(
                // initialValue: editDetails?.mobile ?? '',
                controller: mobNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mobile Number',
                    hintText: 'Mobile Number'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length > 10) {
                    return 'Please enter valid Mobile Number';
                  }
                  return null;
                },
              ),
            ),
            Visibility(
                visible: errorFlag,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red.shade500),
                  ),
                ))
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              child: const Text('Apply'),
              onPressed: () {
                setFilter();
              }),
        ),
      ],
    );
  }
}
