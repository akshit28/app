import 'package:flutter/material.dart';
import 'package:aap/util/dropDown.dart';
import 'package:aap/services/account_service.dart';
import "package:intl/intl.dart";
import 'package:aap/services/scan_service.dart';
import 'package:month_year_picker/month_year_picker.dart';
import "package:intl/intl.dart";
import 'dart:convert';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/user_model.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  var sharedIns = SharedPref();
  List facility = [];
  // String selectedYear = '';
  DropdownOption? selectedFacility;
  String defaultFacility = "e6cbafb5-d84e-4397-b8c6-1277a40a75cc";
  bool emptyResult = false;
  bool loading = false;
  late List paymentsList = [];
  String selectedMonth = (DateTime.now().month).toString();
  String selectedYear = DateTime.now().year.toString();

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  String dateString = "Select Month";

  @override
  void initState() {
    super.initState();
    populateFacilities();
    dateString = "${months[int.parse(selectedMonth) - 1]}, $selectedYear";
  }

  populateFacilities() async {
    // late List facilities;
    // var scan = ScanService();
    // final facilityList = await scan.getFacility();
    // facilities = facilityList.data.facilities;

    List userOrg = await sharedIns.getValueAsStringList('orgList');
    List userFacilityList =
        userOrg.map((item) => Facility.fromJson(jsonDecode(item))).toList();

    facility = [];
    facility = userFacilityList.map((item) {
      return DropdownOption(
        value: item.id,
        displayText: item.name,
      );
    }).toList();

    if (facility.length == 1) {
      selectedFacility = facility[0];
      defaultFacility = facility[0].id;
      getPayments(facility[0].id);
    }
    setState(() {});
  }

  Future selectMonth(BuildContext context) async {
    DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023, 12),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked.month.toString();
        selectedYear = picked.year.toString();
        dateString = '${months[picked.month - 1]}, ${picked.year}';
      });
      getPayments(defaultFacility);
    }
  }

  Future getPayments(String facility) async {
    var account = AccountService();
    paymentsList.clear();

    final data =
        await account.fetchPayments(facility, selectedYear, selectedMonth);

    if (data.success) {
      emptyResult = false;
      paymentsList = data.data;
    } else {
      emptyResult = true;
      paymentsList = [];
    }

    loading = false;
    setState(() {});
  }

  void handleFacilityonchange(newValue) {
    setState(() {
      defaultFacility = newValue.value;
      selectedFacility = newValue;
    });
    getPayments(defaultFacility);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
                visible: facility.length > 1 ? true : false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey.shade400,
                  minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () async {
                  selectMonth(context);
                },
                // child: Text(dateString)
                child: Text(
                  dateString,
                  style: const TextStyle(
                      fontSize: 24,
                      fontFamily: "Cairo",
                      color: Color.fromRGBO(0, 0, 0, 1)),
                ),
              ),
            ),
            emptyResult
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(15, 40, 15, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("No Credit note Found."),
                    ),
                  )
                : const SizedBox.shrink(),
            loading
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(15, 40, 15, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Visibility(
                    visible: paymentsList.isNotEmpty ? true : false,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ListView.builder(
                                    physics: const ScrollPhysics(),
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: paymentsList.length,
                                    itemBuilder: (context, index) {
                                      final note = paymentsList[index];

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 8),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 10, 5),
                                                  child: RichText(
                                                    text: TextSpan(
                                                        text: 'Payment Date: ',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                        children: [
                                                          TextSpan(
                                                            text: DateFormat("dd-MM-yy").format(DateTime.parse(note.date.toString()).toLocal()),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          )
                                                        ]),
                                                  )),
                                                  Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 5),
                                                child: RichText(
                                                  // textAlign: TextAlign.end,
                                                  text: TextSpan(
                                                      text: 'Payment Method: ',
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                          text: note.paymentMethod,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        )
                                                      ]),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 5),
                                                child: RichText(
                                                  // textAlign: TextAlign.end,
                                                  text: TextSpan(
                                                      text: 'Payment: ',
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "Rs. ${note.amount}",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        )
                                                      ]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            ])),
                  )
          ],
        ),
      ),
    );
  }
}
