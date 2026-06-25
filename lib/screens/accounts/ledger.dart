import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'dart:convert';
import "package:aap/models/statement_model.dart";
import "package:aap/services/account_service.dart";
import 'package:aap/util/dropDown.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/user_model.dart';

class AccountLedger extends StatefulWidget {
  const AccountLedger({super.key});

  @override
  State<AccountLedger> createState() => _AccountLedgerState();
}

class _AccountLedgerState extends State<AccountLedger> {
  List statement = [];
  bool loading = false;
  List facilities = [];
  DropdownOption? selectedFacility;
  List trxnType = ["ALL","DEDUCTION", "PAYMENT", "CREDIT_NOTE"];
  List trnType = [];
  var sharedIns = SharedPref();


  @override
  void initState() {
    trnType = trxnType.map((item) {
      return DropdownOption(
        value: item,
        displayText: item.replaceAll(RegExp('_'), ' '),
      );
    }).toList();
    getFacility();
    super.initState();
  }

  getFacility() async {
    List userOrg = await sharedIns.getValueAsStringList('orgList');
    List userOrgList =
        userOrg.map((item) => Facility.fromJson(jsonDecode(item))).toList();

    facilities = userOrgList.map((item) {
      return DropdownOption(
        value: item.id,
        displayText: item.name,
      );
    }).toList();

    if (facilities.length == 1) {
      selectedFacility = facilities[0];
      fetchStatement();
    }

    setState(() {});
  }

  void handleFacilityOnchange(newValue){
    setState(() {
      selectedFacility = newValue;
    });
    fetchStatement();
  }


  fetchStatement({String startDate = "", String txnType = ""}) async {
    String org = "e6cbafb5-d84e-4397-b8c6-1277a40a75cc";
    var account = AccountService();
    statement.clear();
    loading = true;
    setState(() {});

    final data = await account.fetchStatements(selectedFacility!.value, startDate, txnType);

    if (data.success) {
      statement = data.data;
    } else {
      statement = [];
    }

    loading = false;
    setState(() {});
  }

  void _showPopupMenu(BuildContext context) async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 1,
      //     backgroundColor: Colors.blue,
      //     title: const Text("Statement"),
      // ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
             Visibility(
              visible: facilities.length > 1 ? true : false,
              child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.grey),
                      )),
                      hint: const Text("Select Facility"),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: facilities
                          .map((item) => DropdownMenuItem<DropdownOption>(
                              value: item, child: Text(item.displayText)))
                          .toList(),
                      onChanged: handleFacilityOnchange,
                      value: selectedFacility,
                    )),
            ),
            loading ? const Padding(
                    padding: EdgeInsets.fromLTRB(15, 40, 15, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ) :
            Expanded(
                child: ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: statement.length,
                    itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Card(
                            color: const Color(0XFFFFFFFF),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        // width: 400,
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          spacing: 2,
                                          children: [
                                            Text(
                                              DateFormat('dd-MM-yy').format(
                                                  DateTime.parse(
                                                          statement[index]
                                                              .createdAt)
                                                      .toLocal()),
                                              style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(statement[index].description)
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        // width: 400,
                                        child: Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.end,
                                          runAlignment: WrapAlignment.end,
                                          direction: Axis.vertical,
                                          spacing: 2,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                  text: statement[index]
                                                      .amount
                                                      .replaceAll(
                                                          RegExp('-'), ''),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Cairo',
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                    TextSpan(
                                                      text: double.parse(
                                                                  statement[
                                                                          index]
                                                                      .amount) <
                                                              0
                                                          ? ' Dr'
                                                          : ' Cr',
                                                      style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 14,
                                                          color: double.parse(statement[
                                                                          index]
                                                                      .amount) <
                                                                  0
                                                              ? Colors
                                                                  .red.shade600
                                                              : Colors.green
                                                                  .shade600),
                                                    )
                                                  ]),
                                            ),
                                            RichText(
                                                text: TextSpan(
                                                    text: "Balance: ",
                                                    style: const TextStyle(
                                                        fontFamily: "Cairo",
                                                        fontSize: 14),
                                                    children: [
                                                  TextSpan(
                                                      text: statement[index]
                                                          .balance,
                                                      style: const TextStyle(
                                                        fontFamily: "Cairo",
                                                      ))
                                                ]))
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPopupMenu(context);
        },
        tooltip: 'Filters',
        child: const Icon(Icons.filter_alt_outlined),
      ),
    );
  }
}
