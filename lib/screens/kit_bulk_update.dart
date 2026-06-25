import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:aap/util/snackbar.dart';
import 'package:aap/services/kit_service.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/models/kitbatch_model.dart';

class KitBulkUpdate extends StatefulWidget {
  const KitBulkUpdate({super.key});

  @override
  State<KitBulkUpdate> createState() => _KitBulkUpdateState();
}

class _KitBulkUpdateState extends State<KitBulkUpdate> {
  final _formKey = GlobalKey<FormState>();
  final qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  late List fetchedReasons;
  late List facilities;
  var kitMap = {};
  List tempKitArray = [];
  bool isLoading = false;
  bool isRequesting = false;
  bool toggleReason = false;
  bool isFree = false;

  List reasons = [];
  DropdownOption? selectedReasons;

  List status = [];
  DropdownOption? selectedStatus;

  List facility = [];
  DropdownOption? selectedFacility;

  void handleReasonOnchange(newValue) {
    setState(() {
      selectedReasons = newValue;
    });
  }

  void handleFacilityonchange(newValue) {
    setState(() {
      selectedFacility = newValue;
    });
  }

  void handleStatusOnchange(newValue) {
    bool statusValCnd = (newValue.displayText == "UNUSABLE");
    setState(() {
      if(statusValCnd){
        toggleReason = true;
      }else{
        toggleReason = false;
      }
      selectedStatus = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchKitInvalidReasons();
    fetchStatuses();
    populateFacilities();
  }

  fetchStatuses() async {
    print("fetchStatuses called *******");
    var kit = KitService();
    final data = await kit.fetchKitStatuses();

    if (data.success) {
      status = [];
      status = data.data.map((item) {
        return DropdownOption(
          value: item.id,
          displayText: item.name,
        );
      }).toList();
      setState(() {});
    } else {}
  }

  openScanDialog(BuildContext context) {
    qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
        context: context,
        onCode: (code) {
          final rawString = code!.replaceAll("'", '"');
          final kitcode = jsonDecode(rawString);
          fetchKitDetails(context, kitcode['type'], kitcode['code']);
          Future.delayed(const Duration(seconds: 2), () {
            openScanDialog(context);
          });
        });
  }

  fetchKitDetails(
      BuildContext context, String type, String fetchedKitCode) async {
    var kit = KitService();
    final data = await kit.getKitDeatils(fetchedKitCode);

    if (data.success) {
      if (data.data[0].statusCode != "USED") {
        if (!kitMap.containsKey(data.data[0].testGroup[0].code)) {
          kitMap[data.data[0].testGroup[0].code] = [];
          // kitMap[data.data[0].testGroup[0].code].
          // for(var item in kitMap[data.data[0].testGroup[0].code]){
          //   if(item)
          // }
          if (!tempKitArray.contains(data.data[0].code)) {
            kitMap[data.data[0].testGroup[0].code].add(KitsMap(
                id: data.data[0].id,
                code: data.data[0].code,
                status: data.data[0].status));
            tempKitArray.add(data.data[0].code);
            if (mounted) {
              const CustomSnackBar(
                      seconds: 1, text: 'Kit added.', type: 'success')
                  .show(context);
            }
          } else {
            if (mounted) {
              const CustomSnackBar(
                      seconds: 1, text: 'Kit is already added.', type: 'error')
                  .show(context);
            }
          }
        } else {
          if (!tempKitArray.contains(data.data[0].code)) {
            kitMap[data.data[0].testGroup[0].code].add(KitsMap(
                id: data.data[0].id,
                code: data.data[0].code,
                status: data.data[0].status));
            tempKitArray.add(data.data[0].code);
            if (mounted) {
              const CustomSnackBar(
                      seconds: 1, text: 'Kit added.', type: 'success')
                  .show(context);
            }
          } else {
            if (mounted) {
              const CustomSnackBar(
                      seconds: 1, text: 'Kit is already added.', type: 'error')
                  .show(context);
            }
          }
        }

        setState(() {});
      } else {
        if (mounted) {
          const CustomSnackBar(
                  seconds: 1, text: 'Kit is already used.', type: 'error')
              .show(context);
        }
      }
      // print(kitMap);
    } else {
      if (mounted) {
        const CustomSnackBar(
                seconds: 1, text: 'Kit Code record not found', type: 'error')
            .show(context);
      }
    }
  }

  fetchKitInvalidReasons() async {
    print("fetchKitInvalidReasons called ****");
    var kit = KitService();
    final data = await kit.fetchKitInvalidReasons();

    if (data.success) {
      fetchedReasons = data.data;
      print("fetchKitInvalidReasons called response ****");
      reasons = [];
      reasons = fetchedReasons.map((item) {
        return DropdownOption(
          value: item.id,
          displayText: item.description,
        );
      }).toList();
      setState(() {});
    } else {
      //TODO
    }
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
    // facilities.where((element) => element.)
    if (facilities.length == 1) {
      selectedFacility = facility[0];
    }
    setState(() {});
  }

  submitResponse(BuildContext context) async {
    List updatedKits = [];
    const obj = {};
    var kit = KitService();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      isRequesting = true;
    });

    if (kitMap.isNotEmpty) {
      kitMap.values.forEach((element) {
        // updatedKits.add(value)
        isFree ? 
        element.forEach((val) {
          updatedKits.add({
              "id": val.id,
              "facility": selectedFacility!= null ? selectedFacility!.value : '',
              "kitRejectionReason":
                  selectedReasons != null ? selectedReasons!.value : '',
              "status": selectedStatus != null ? selectedStatus!.value : '',
              "mrp": 0,
          }
              ); 
          // obj['id'] = val.id;
          // obj['facility'] = selectedFacility!= null ? selectedFacility!.value : '';
          // obj['kitRejectionReason'] = selectedReasons != null ? selectedReasons!.value : '';
          // obj['status'] = selectedStatus != null ? selectedStatus!.value : '';
          // obj['mrp'] = 0;
          // updatedKits.add(obj);
        })
        : element.forEach((val) {
          updatedKits.add(KitBatch(
              id: val.id,
              facility: selectedFacility!= null ? selectedFacility!.value : '',
              kitRejectionReason:
                  selectedReasons != null ? selectedReasons!.value : '',
              status: selectedStatus != null ? selectedStatus!.value : ''));
        });
      });

      // print(updatedKits);
      final data = await kit.kitStatusBatchUpload(updatedKits);

      if (data["success"]) {
        kitMap = {};
        selectedReasons = null;
        selectedFacility = null;
        if (mounted) {
          const CustomSnackBar(
                  seconds: 1, text: 'Kit deatils submitted', type: 'success')
              .show(context);
        }
      } else {
        if (mounted) {
          CustomSnackBar(seconds: 1, text: data["error"], type: 'error')
              .show(context);
        }
      }

      isRequesting = false;
      isLoading = false;
      setState(() {});
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.blue,
          title: const Text("Kit Batch Update Form"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
                key: _formKey,
                child: Column(
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
                            openScanDialog(context);
                          },
                          child: const Text('Scan Kit QR Code'),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: kitMap.isNotEmpty,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                                    child: Text("Scanned Kits:",
                                        style: TextStyle(fontSize: 20))),
                                kitMap.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemCount: kitMap.length,
                                        itemBuilder: (context, index) {
                                          final keys = kitMap.keys.toList();
                                          final values = kitMap.values.toList();
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                              child: Card(
                                                  child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 5, 10, 5),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${keys[index]} - ${values[index].length}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 5, 10, 5),
                                                    child: Row(
                                                      children: [
                                                        for (KitsMap item
                                                            in values[index])
                                                          Text(
                                                            // item['code'].to + ', ',
                                                            '${item.code}, ',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              )));
                                        })
                                    : const Center(child: Text("Scan QR"))
                              ],
                            ))),
                    Padding(
                        padding: const EdgeInsets.all(15),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey),
                          )),
                          hint: const Text("Assign New Facility"),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: facility
                              .map((item) => DropdownMenuItem<DropdownOption>(
                                  value: item, child: Text(item.displayText)))
                              .toList(),
                          onChanged: handleFacilityonchange,
                          value: selectedFacility,
                          // validator: (value) =>
                          //     value == null ? 'Assign a new facility' : null,
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
                          hint: const Text("Update Kits Status"),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: status
                              .map((item) => DropdownMenuItem<DropdownOption>(
                                  value: item, child: Text(item.displayText)))
                              .toList(),
                          onChanged: handleStatusOnchange,
                          value: selectedStatus,
                          validator: (value) => value == null
                              ? 'Select to update kits status'
                              : null,
                        )),
                        Visibility(
                          visible: toggleReason,
                          child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.grey),
                            )),
                            hint: const Text("Select Reason"),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: reasons
                                .map((item) => DropdownMenuItem<DropdownOption>(
                                    value: item, child: Text(item.displayText)))
                                .toList(),
                            onChanged: handleReasonOnchange,
                            value: selectedReasons,
                            // validator: (value) =>
                            //     value == null ? 'Please select a Reason' : null,
                          )),
                        ),
                        Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isFree,
                              onChanged: (value) {
                                setState(() {
                                  isFree = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text("Free Kits")
                          ],
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
                                onPressed: () => isRequesting
                                    ? null
                                    : submitResponse(context),
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
                ))));
  }
}

class DropdownOption {
  final String displayText;
  final String value;

  @override
  int get hashCode => super.hashCode;

  DropdownOption({
    required this.displayText,
    required this.value,
  });
}

class KitsMap {
  final String id;
  final String code;
  final String status;
  // final String facility;

  KitsMap({
    required this.id,
    required this.code,
    required this.status,
    // required this.facility
  });
}
