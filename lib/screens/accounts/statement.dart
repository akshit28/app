import 'package:flutter/material.dart';
import 'package:aap/models/accountstatement_model.dart';
import 'dart:convert';
import 'package:aap/util/snackbar.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:aap/services/account_service.dart';
import "package:intl/intl.dart";
import 'package:aap/services/scan_service.dart';
import "package:url_launcher/url_launcher.dart";
import 'package:aap/util/dropDown.dart';
import 'package:aap/models/invoiceitem_model.dart' as Invoice;
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/user_model.dart';

class AccountStatement extends StatefulWidget {
  const AccountStatement({super.key});

  @override
  State<AccountStatement> createState() => _AccountStatementState();
}

class _AccountStatementState extends State<AccountStatement> {
  var sharedIns = SharedPref();
  String selectedYear = '';
  String defaultFacility = "1bf37b41-3a7a-412a-990a-273ecf1e43d8";
  List<Datum> accountData = [];
  bool loading = false;
  late List facilities;
  bool emptyResult = false;
  bool showDetails = false;

  String selectedMonth = (DateTime.now().month).toString();
  String currentYear = DateTime.now().year.toString();
  List<Invoice.InvoiceItemModel> invoiceRows = [];

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
  List facility = [];
  DropdownOption? selectedFacility;

  @override
  void initState() {
    super.initState();
    populateFacilities();
    dateString = "${months[int.parse(selectedMonth) - 1]}, $currentYear";
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
      getStatement(selectedMonth, selectedYear, defaultFacility);
    }
  }

  void handleFacilityonchange(newValue) {
    setState(() {
      defaultFacility = newValue.value;
      selectedFacility = newValue;
    });
  }

  openLink(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  populateFacilities() async {
    // var scan = ScanService();
    // final facilityList = await scan.getFacility();
    // facilities = facilityList.data.facilities;

    List userOrg = await sharedIns.getValueAsStringList('orgList');
    List userFacilityList =
        userOrg.map((item) => Facility.fromJson(jsonDecode(item))).toList();


    facility = [];
    facilities = userFacilityList;
    facility = userFacilityList.map((item) {
      return DropdownOption(
        value: item.id,
        displayText: item.name,
      );
    }).toList();
    if (facility.length == 1) {
      selectedFacility = facility[0];
      defaultFacility = facility[0].id;
      getStatement(selectedMonth, currentYear, facility[0].id);
    }
    setState(() {});
  }

  getFacilityName(String facility) {
    // String facilityName = '';
    var facilityName =
        facilities.firstWhere((element) => element.id == facility);

    // if(facilityName.name != -1){
    return facilityName?.name ?? '';
    // }else{
    //   return "";
    // }
  }

  Future getStatement(
      String selectedMonth, String selectedYear, String facility) async {
    List<Invoice.InvoiceItemModel>? invItem;
    var account = AccountService();
    accountData.clear();
    invoiceRows.clear();
    loading = true;
    final data =
        await account.fetchStatement(selectedMonth, selectedYear, facility);

    if (data.success) {
      emptyResult = false;
      accountData = data.data;
      // accountData.in
      accountData[0].invoiceItemGrouped.forEach((item) {
        invoiceRows.add(
            Invoice.InvoiceItemModel(itemList: [], itemCode: item.itemCode));
      });

      // accountData[0].invoiceItems.map((item) {
      //   Invoice.InvoiceItemModel deviceExists = invoiceRows.firstWhere((obj) => obj.itemCode == item.objectCode);
      //   deviceExists.itemList.add(item);
      // });

      for (var item in accountData[0].invoiceItems) {
        Invoice.InvoiceItemModel deviceExists =
            invoiceRows.firstWhere((obj) => obj.itemCode == item.objectCode);
        deviceExists.itemList.add(item);
      }

      print("statement **********");
      print(invoiceRows[0].itemList);
    } else {
      emptyResult = true;
      accountData = [];
    }

    loading = false;
    setState(() {});
  }

  statusColor(String status) {
    switch (status) {
      case "PAID":
        return Colors.green.shade400;
      default:
        return Colors.redAccent;
    }
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
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
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
            ? Padding(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Text("No Invoice Found for the month of $dateString"),
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
                visible: accountData.isNotEmpty ? true : false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Text("Invoices:",
                              style: TextStyle(fontSize: 20))),
                      SizedBox(
                        width: double.infinity,
                        // height: double.infinity,
                        //height: MediaQuery.of(context).size.height - 220,
                        child: ListView.builder(
                            // physics: const BouncingScrollPhysics(),
                            physics: const ScrollPhysics(),
                            itemCount: accountData.length,
                            // scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              final category = accountData[index];
                              // final List items = category.invoiceItemGrouped;
                              // final List childItems = category.invoiceItems;
                              // List<DataRow> childRows = [];
                              // List<DataRow> detailChildRows = [];

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 5),
                                          child: RichText(
                                            text: TextSpan(
                                                text: 'Billing cycle: ',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${DateFormat("dd-MM-yy").format(DateTime.parse(category.fromDate.toString()).toLocal())} to ${DateFormat("dd-MM-yy").format(DateTime.parse(category.toDate.toString()).toLocal())}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  )
                                                ]),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        child: RichText(
                                          text: TextSpan(
                                              text: 'Date: ',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: DateFormat(
                                                          "dd-MM-yy HH:mm:ss")
                                                      .format(DateTime.parse(
                                                              category
                                                                  .createdAt)
                                                          .toLocal()),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                )
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        child: RichText(
                                          text: TextSpan(
                                              text: 'Invoice No: ',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      category.code.toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                )
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        child: RichText(
                                          text: TextSpan(
                                              text: 'Bill To: ',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: getFacilityName(
                                                      category.facility),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                )
                                              ]),
                                        ),
                                      ),
                                     
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                        child: Container(
                                          color: Colors.grey.shade300,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                              child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(5, 8, 25, 8),
                                              child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                            
                                          ],
                                        ),
                                        ),
                                        ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: category
                                                .invoiceItemGrouped.length * 60,
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        child: ListView.builder(
                                            physics: const BouncingScrollPhysics(),
                                            // physics:
                                            //     const NeverScrollableScrollPhysics(),
                                            itemCount: category
                                                .invoiceItemGrouped.length,
                                            itemBuilder:
                                                (BuildContext context, index) {
                                              Invoice.InvoiceItemModel
                                                  invoiceItem = invoiceRows
                                                      .firstWhere((element) =>
                                                          element.itemCode ==
                                                          category
                                                              .invoiceItemGrouped[
                                                                  index]
                                                              .itemCode);
                                              // print(invoiceItem.itemList);

                                              return ExpansionTile(
                                                // trailing: Icon(
                                                // _customTileExpanded
                                                //     ? Icons.arrow_drop_down_circle
                                                //     : Icons.arrow_drop_down),
                                                tilePadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                controlAffinity: ListTileControlAffinity.platform,
                                                childrenPadding: const EdgeInsets.all(0),
                                                // leading: Container(),
                                                // initiallyExpanded: true,    
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Wrap(
                                                      direction: Axis.vertical,
                                                      children: [
                                                          SizedBox(
                                                            width: 200,
                                                            child: Text(category.invoiceItemGrouped[index].type == 'DeviceMaster' ? category.invoiceItemGrouped[index].itemCode : category.invoiceItemGrouped[index].itemName, 
                                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis,)
                                                            ),
                                                          ),
                                                          
                                                          Text("Price: Rs. ${category.invoiceItemGrouped[index].amount}, ${category.invoiceItemGrouped[index].type == 'DeviceMaster' ? 'Days' : 'Qty.'}: ${category.invoiceItemGrouped[index].quantity.toString()}", style: const TextStyle(fontSize: 14),)
                                                      ],
                                                    ),
                                                    
                                                    // const Spacer(),
                                                    Text("Rs. ${category.invoiceItemGrouped[index].charges}",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ))

                                                  ],
                                                ),

                                                children: [
                                                  SizedBox(
                                                      width: double.infinity,
                                                      height: invoiceItem
                                                              .itemList.length *
                                                          150,
                                                      child: ListView.builder(
                                                          physics: const ScrollPhysics(),
                                                          itemCount: invoiceItem
                                                              .itemList.length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  pointer) {
                                                            return Padding(
                                                              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Wrap(
                                                                    direction: Axis
                                                                        .vertical,
                                                                    children: [
                                                                      invoiceItem.itemList[pointer].contentTypeEntity ==
                                                                              'device master'
                                                                          ? Text(
                                                                              invoiceItem.itemList[pointer].itemCode,
                                                                              style:
                                                                                  const TextStyle(fontWeight: FontWeight.bold),
                                                                            )
                                                                          : Text(
                                                                              invoiceItem.itemList[pointer].contentObject.name,
                                                                              style:
                                                                                  const TextStyle(fontWeight: FontWeight.bold)),
                                                                      invoiceItem.itemList[pointer].contentTypeEntity !=
                                                                              'device master'
                                                                          ? Text(
                                                                              "Batch: ${invoiceItem.itemList[pointer].contentObject.batch}")
                                                                          : const SizedBox
                                                                              .shrink(),
                                                                      Text(
                                                                          "HSN: ${invoiceItem.itemList[pointer].contentObject.hsn}"),
                                                                      invoiceItem.itemList[pointer].contentTypeEntity ==
                                                                              'device master'
                                                                          ? Text(
                                                                              "Subscription: Rs ${invoiceItem.itemList[pointer].contentObject.subscriptionFee}/Month")
                                                                          : Text(
                                                                              "Mrp: Rs ${invoiceItem.itemList[pointer].contentObject.mrp}"),
                                                                      Text(
                                                                          "SGST(${invoiceItem.itemList[pointer].contentObject.sgst}%:) ${invoiceItem.itemList[pointer].sgst}"),
                                                                      Text(
                                                                          "CGST(${invoiceItem.itemList[pointer].contentObject.cgst}%): ${invoiceItem.itemList[pointer].cgst}"),
                                                                      invoiceItem.itemList[pointer].contentTypeEntity ==
                                                                              'device master'
                                                                          ? Text(
                                                                              "Charged Days: ${invoiceItem.itemList[pointer].quantity}")
                                                                          : Text(
                                                                              "Qty: ${invoiceItem.itemList[pointer].quantity}"),
                                                                      Text(
                                                                          "Amount: Rs. ${invoiceItem.itemList[pointer].charges}"),
                                                                    ],
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    "Rs. ${invoiceItem.itemList[pointer].total}",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }))
                                                ],
                                              );
                                            }),
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 15, 10),
                                            child: RichText(
                                              textAlign: TextAlign.end,
                                              text: TextSpan(
                                                  text: 'Amount: ',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "Rs. ${category.amount}",
                                                      style: const TextStyle(
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
                                       Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 15, 10),
                                            child: RichText(
                                              textAlign: TextAlign.end,
                                              text: TextSpan(
                                                  text: 'SGST: ',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "Rs. ${category.sgst}",
                                                      style: const TextStyle(
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
                                       Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 15, 10),
                                            child: RichText(
                                              textAlign: TextAlign.end,
                                              text: TextSpan(
                                                  text: 'CGST: ',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "Rs. ${category.cgst}",
                                                      style: const TextStyle(
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 15, 15),
                                            child: RichText(
                                              text: TextSpan(
                                                  text: 'Total Amount: ',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "Rs. ${category.grandTotal}",
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
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 5, 5, 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // TextButton(
                                            //     onPressed: () {
                                            //       setState(() {
                                            //         showDetails = !showDetails;
                                            //       });
                                            //     },
                                            //     child: Text(!showDetails
                                            //         ? 'Show Details'
                                            //         : 'Hide Details')),
                                            const Spacer(),
                                            category.pdf != null &&
                                                    !category.pdf.isEmpty
                                                ? TextButton(
                                                    onPressed: () {
                                                      openLink(Uri.parse(
                                                          category.pdf));
                                                    },
                                                    child: const Text(
                                                        "Invoice Link"))
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      // )
                    ],
                  ),
                )),
      ],
    )));
  }
}
