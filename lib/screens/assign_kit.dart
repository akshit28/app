import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:aap/services/kit_service.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/user_model.dart';
import 'package:aap/util/dropDown.dart';

class AssignKit extends StatefulWidget {
  const AssignKit({super.key});

  @override
  State<AssignKit> createState() => _AssignKitState();
}

class _AssignKitState extends State<AssignKit> {
  var sharedIns = SharedPref();
  bool kitDetail = false;
  bool loading = false;
  List facilities = [];
  DropdownOption? selectedFacility;

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
    }
    setState(() {});
  }

  void handleFacilityOnchange(newValue){
    setState(() {
      selectedFacility = newValue;
    });
  }

  fetchKitDetails(
      BuildContext context, String type, String fetchedKitCode) async {
    var kit = KitService();
    final data = await kit.fetchKitDetails(type, fetchedKitCode);

    if (data.success) {
    } else {}
  }

  markKitInUse(String facility, String id, String status) async {
    var kit = KitService();

    final data = await kit.markKitInUse(facility, id, status);

    if (data.success) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Mark Kit"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Visibility(visible: kitDetail, child: Text("Show"))
          ],
        ),
      ),
    );
  }
}
