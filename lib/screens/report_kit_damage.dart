import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/services/kit_service.dart';
import 'package:aap/util/snackbar.dart';
// import 'package:camera/camera.dart';
// import 'package:permission_handler/permission_handler.dart';
import "package:intl/intl.dart";

// late List<CameraDescription> _cameras;
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   _cameras = await availableCameras();
//   runApp(const ReportKitDamage());
// }

class ReportKitDamage extends StatefulWidget {
  const ReportKitDamage({super.key});

  @override
  State<ReportKitDamage> createState() => _ReportKitDamageState();
}

class _ReportKitDamageState extends State<ReportKitDamage> {
  final _formKey = GlobalKey<FormState>();
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final kitCode = TextEditingController();
  final testName = TextEditingController();
  final remarks = TextEditingController();
  final kitCurrentStatus = TextEditingController();
  final kitCurrentFacility = TextEditingController();
  late String selectedTestId;
  String? kitStatus;
  late String kitId;
  String kitCreatedAt = '';
  String kitExpiryDate = '';
  String kitUpdatedDate = '';
  late String facilityId;
  bool isLoading = false;
  bool isRequesting = false;
  File imgFile = File('');
  late List facilities;
  late List fetchedReasons;
  List currentFacility = [];
  late List currentReason;
  bool toggleReason = false;
  bool toggleKitCard = false;
  String kitCodeVal = '';
  String testGroupName = '';

  // CameraController? _controller;
  // late List<CameraDescription> cameras;
  // List<CameraDescription> firstCamera = <CameraDescription>[];
  // late CameraDescription firstCamera;

  List reasons = [];
  DropdownOption? selectedReasons;

  List status = [];
  DropdownOption? selectedStatus;

  List facility = [];
  DropdownOption? selectedFacility;

  @override
  void initState() {
    super.initState();
    fetchKitInvalidReasons();
    fetchStatuses();
    populateFacilities();
  }

  // Future<void> _initializeCamera(BuildContext context) async {
  //   final cameras = await availableCameras();
  //   final firstCamera = cameras.first;
  //   _controller = CameraController(
  //     firstCamera,
  //     ResolutionPreset.medium,
  //   );

  //   try {
  //     await _controller!.initialize();
  //     print("Camera Intialized");
  //     _showDialog(context);
  //   } catch (e) {
  //     print('Error initializing camera: $e');
  //   }

  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {});
  // }

  @override
  void dispose() {
    // _controller?.dispose();
    super.dispose();
  }

  void handleReasonOnchange(newValue) {
    setState(() {
      selectedReasons = newValue;
    });
  }

  void handleStatusOnchange(newValue) {
    bool statusValCnd = (newValue.displayText == "UNUSABLE");
    if (statusValCnd) {
      toggleReason = true;
    } else {
      toggleReason = false;
    }
    selectedStatus = newValue;
    setState(() {});
  }

  void handleFacilityonchange(newValue) {
    setState(() {
      selectedFacility = newValue;
    });
  }

  fetchKitDetails(
      BuildContext context, String type, String fetchedKitCode) async {
    var kit = KitService();
    final data = await kit.getKitDeatils(fetchedKitCode);

    if (data.success) {
      // final kitDetails = KitCodeDetailsModel.fromJson(json.decode(data));
      if (data.data[0].statusCode == "USED") {
        isRequesting = true;
      }else{
        isRequesting = false;
      }

        kitCodeVal = data.data[0].code;
        kitCode.text = data.data[0].code;
        // if(data.data[0].testGroup.length == 1){
          testName.text = data.data[0].testGroup[0].code;
          selectedTestId = data.data[0].testGroup[0].id;
        // }else{

        // }
        
        kitStatus = data.data[0].statusCode;
        kitCurrentStatus.text = data.data[0].statusCode;
        kitId = data.data[0].id;

        kitCreatedAt = DateFormat("dd-MM-yy HH:mm:ss").format(
            DateTime.parse(data.data[0].createdAt.toString()).toLocal());
        kitExpiryDate = DateFormat("dd-MM-yy HH:mm:ss").format(
            DateTime.parse(data.data[0].expiryDate.toString()).toLocal());
        kitUpdatedDate = DateFormat("dd-MM-yy HH:mm:ss").format(
            DateTime.parse(data.data[0].updatedAt.toString()).toLocal());
        // kitExpiryDate = data.data[0].expiryDate;
        if (data.data[0]!.facility != null) {
          facilityId = data.data[0]!.facility;
          if (facility.isNotEmpty && facilityId.isNotEmpty) {
            currentFacility = facilities
                .where((element) => element.id == facilityId)
                .toList();
            // DropdownOption currentFacility = facility.where((element) => element.value == facilityId);
            kitCurrentFacility.text = currentFacility[0].name;
            // testGroupName = currentFacility[0].name;
            // print(currentFacility[0].value);
          }
        } else {
          facilityId = "";
        }

        if (data.data[0].testGroup.isNotEmpty) {
          testGroupName = data.data[0].testGroup[0].code;
        }

        if (data.data[0].kitRejectionReason != null &&
            data.data[0].kitRejectionReason.isNotEmpty &&
            fetchedReasons.isNotEmpty) {
          currentReason = fetchedReasons
              .where((element) => element.id == data.data[0].kitRejectionReason)
              .toList();
          // currentReason = displayText
          print(currentReason[0].name);
        } else {
          // currentReason = null;
        }
        toggleKitCard = true;
        setState(() {});
      // } else {
      //   if (mounted) {
      //     const CustomSnackBar(
      //             seconds: 1, text: 'Kit is already used.', type: 'error')
      //         .show(context);
      //   }
      // }
    } else {
      if (mounted) {
        const CustomSnackBar(
                seconds: 1, text: 'Kit Code record not found', type: 'error')
            .show(context);
      }
    }
  }

  validateKitcode(BuildContext context, String val) async {
    if (val.length >= 6) {
      fetchKitDetails(context, 'kit', val);
    }
  }

  submitResponse(BuildContext context) async {
    var kit = KitService();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      isRequesting = true;
    });

    var payload = {
      "kitRejectionReason":
          selectedReasons != null ? selectedReasons!.value : "",
      "id": kitId,
      "code": kitCode.text,
      "testGroup": selectedTestId,
      "currentFacility": facilityId != null ? facilityId : "",
      "newfacility": selectedFacility != null ? selectedFacility!.value : "",
      "kitCurrentStatus": kitStatus,
      "kitUpdatedStatus": selectedStatus != null ? selectedStatus!.value : "",
    };

    final data = await kit.submitKitDamage(payload);

    if (data["success"]) {
      kitCode.clear();
      remarks.clear();
      testName.clear();
      kitCurrentFacility.clear();
      kitCurrentStatus.clear();
      selectedReasons = null;
      selectedStatus = null;
      selectedFacility = null;
      toggleReason = false;
      toggleKitCard = false;
      if (mounted) {
        const CustomSnackBar(
                seconds: 1, text: 'Kit deatils submitted', type: 'success')
            .show(context);
      }
    } else {
      if (mounted) {
        CustomSnackBar(seconds: 1, text: data.error, type: 'error')
            .show(context);
      }
    }
    isRequesting = false;
    isLoading = false;
    setState(() {});
  }

  // Future<void> _takePicture(BuildContext context) async {
  //   if (_controller == null || !_controller!.value.isInitialized) {
  //     return;
  //   }

  //   if (await Permission.camera.request().isGranted) {
  //     try {
  //       final XFile picture = await _controller!.takePicture();
  //       // 'picture' now contains the path to the captured image
  //       print('Image path: ${picture.path}');
  //       imgFile = File(picture.path);
  //       setState(() {});
  //       Navigator.of(context).pop();
  //     } catch (e) {
  //       print('Error taking picture: $e');
  //     }
  //   } else {
  //     print('Camera permission denied');
  //     // AlertDialog()
  //   }
  // }

  // Future<void> _showDialog(BuildContext context) async {
  //   // _initializeCamera();
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Dialog(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               AspectRatio(
  //                 aspectRatio: _controller!.value.aspectRatio,
  //                 child: CameraPreview(_controller!),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   _takePicture(context);
  //                 },
  //                 child: const Text('Take Picture'),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  // cameraDialig(BuildContext context) {
  //   return Dialog(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         AspectRatio(
  //           aspectRatio: 16 / 9,
  //           child: CameraPreview(_controller!),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             _takePicture;
  //           },
  //           child: Text('Take Picture'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  @override
  Widget build(BuildContext context) {
    // if (_controller != null && !_controller!.value.isInitialized) {
    //   return Container(); // Replace with a loading indicator if needed
    // }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Kit Management Form"),
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
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            final rawString = code!.replaceAll("'", '"');
                            final kitcode = jsonDecode(rawString);
                            fetchKitDetails(
                                context, kitcode['type'], kitcode['code']);
                          });
                    },
                    child: const Text('Scan Kit QR Code'),
                  ),
                ),
              ),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Text("OR Enter Kit Code"),
                  Expanded(child: Divider()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: kitCode,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kit Code',
                      hintText: 'Kit Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return 'Please enter valid kit code';
                    }
                    return null;
                  },
                  onChanged: (input) => validateKitcode(context, input),
                ),
              ),
              Visibility(
                  visible: toggleKitCard,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RichText(
                                text: TextSpan(
                                    text: 'Kit Code: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: kitCodeVal,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    text: 'Current Status: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: kitStatus,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    text: 'Test Group Name: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: testGroupName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    text: 'Current facility: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: currentFacility.isNotEmpty
                                            ? currentFacility[0].name
                                            : "",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    text: 'Kit Created At: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: kitCreatedAt,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    text: 'Kit Expiry Date: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: kitExpiryDate,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    text: 'Kit Updated Date: ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: kitUpdatedDate,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ))),
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: TextFormField(
              //     controller: testName,
              //     decoration: const InputDecoration(
              //         border: OutlineInputBorder(),
              //         labelText: 'Test Name',
              //         hintText: 'Test Name'),
              //   ),
              // ),
              // Visibility(
              //     visible: true,
              //     child: Padding(
              //       padding: const EdgeInsets.all(15),
              //       child: TextFormField(
              //         controller: kitCurrentStatus,
              //         readOnly: true,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(),
              //             labelText: 'Kit Current Status',
              //             hintText: 'Kit Current Status'),
              //       ),
              //     )),
              Padding(
                  padding: const EdgeInsets.all(15),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    )),
                    hint: const Text("Update Kit Status"),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: status
                        .map((item) => DropdownMenuItem<DropdownOption>(
                            value: item, child: Text(item.displayText)))
                        .toList(),
                    onChanged: handleStatusOnchange,
                    value: selectedStatus,
                    validator: (value) =>
                        value == null ? 'Select to update kit status' : null,
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
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: TextFormField(
              //     controller: kitCurrentFacility,
              //     readOnly: true,
              //     decoration: const InputDecoration(
              //         border: OutlineInputBorder(),
              //         labelText: 'Kit Current Facility',
              //         hintText: 'Kit Current Facility'),
              //   ),
              // ),
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
                    validator: (value) =>
                        value == null ? 'Assign a new facility' : null,
                  )),
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: TextFormField(
              //     controller: remarks,
              //     textCapitalization: TextCapitalization.characters,
              //     decoration: const InputDecoration(
              //         border: OutlineInputBorder(),
              //         labelText: 'Remarks',
              //         hintText: 'Remarks'),
              //     validator: (value) {
              //       if (value == null || value.isEmpty || value.length != 6) {
              //         return 'Please enter';
              //       }
              //       return null;
              //     },
              //     // onChanged: (input) => validateKitcode(context, input),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: TextButton(
              //       onPressed: () {
              //         // _showDialog(context);
              //         _initializeCamera(context);
              //       },
              //       child: const Text("Take a Picture of Kit")),
              // ),
              // Visibility(
              //     visible: imgFile.path.isNotEmpty ? true : false,
              //     child: Padding(
              //       padding: const EdgeInsets.all(15),
              //       child: Image.file(imgFile,width: 100,height: 100,),
              //     )),
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
                              isRequesting ? null : submitResponse(context),
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

  @override
  int get hashCode => super.hashCode;

  DropdownOption({
    required this.displayText,
    required this.value,
  });
}
