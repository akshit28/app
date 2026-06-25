import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:aap/services/scan_service.dart';
import 'package:aap/util/snackbar.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({super.key});

  @override
  State<AddPatient> createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateinput = TextEditingController();
  // Object? patientId = ModalRoute.of(context)!.settings.arguments;
  final mobNumber = TextEditingController();
  final patientName = TextEditingController();
  final emailAddress = TextEditingController();
  // final gender = TextEditingController();
  bool smsEnabled = false;
  bool isLoading = false;
  List<DropdownMenuItem<String>> gender = [
    const DropdownMenuItem(value: "Male", child: Text("Male")),
    const DropdownMenuItem(value: "Female", child: Text("Female")),
  ];
  String? selectedGender;
  DateTime _selectedYear = DateTime.now();

  selectYear(BuildContext context) async {
    print("Calling date picker");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              // lastDate: DateTime.now(),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
              selectedDate: _selectedYear,
              onChanged: (DateTime dateTime) {
                // print(dateTime.year);
                setState(() {
                  _selectedYear = dateTime;
                  dateinput.text = "${dateTime.year}";
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  callAddPatient() async {
    var scan = ScanService();

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> payload = {
        'mobile': mobNumber.text.toString(),
        'name': patientName.text.toString(),
        'email': emailAddress.text.toString(),
        'gender': selectedGender.toString().toUpperCase(),
        'dob': DateFormat('yyyy-MM-dd').format(DateTime(int.parse(dateinput.text))),
        'sms': smsEnabled,
        "patientId": null
      };

      final data = await scan.addNewPatient(payload);
      if (data.success) {
        if (mounted) {
          const CustomSnackBar(
                  seconds: 2, text: 'New Patient Added.', type: 'success')
              .show(context);
        }
        _formKey.currentState!.reset();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/scan_form', arguments: {
                                                      'patientId': data.data,
                                                      'patientName': patientName.text.toString()
                                                    });
        });
      } else {
        if (mounted) {
          CustomSnackBar(seconds: 4, text: data.error.toString(), type: 'error')
              .show(context);
        }
        data.error;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  void handleGenderVal(newValue) {
    setState(() {
      selectedGender = newValue;
    });
  }

  @override
  void initState() {
    dateinput.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final editDetails = ModalRoute.of(context)?.settings.arguments;
    // final AddPatients patient = AddPatients.fromJson(jsonDecode(editDetails as String));
    // if(editDetails != null){
    //   final AddPatients patient = AddPatients.fromJson(jsonDecode(editDetails as String));
    //   print(patient);
    // }
    // var mobNum = editDetails!.mobNum;

    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.blue,
          title: const Text("Add a Patient"),
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
                        child: TextFormField(
                          // initialValue: editDetails?.mobile ?? '',
                          controller: mobNumber,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Mobile Number',
                              hintText: 'Mobile Number'),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length > 10) {
                              return 'Please enter valid Mobile Number';
                            }
                            return null;
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(15),
                        child: TextFormField(
                          controller: patientName,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Name',
                              hintText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(15),
                        child: TextFormField(
                          readOnly: true,
                          controller: dateinput,

                          decoration: InputDecoration(
                              labelText: 'Year of Birth',
                              hintText: 'Year of Birth',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.grey),
                              )),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Year of birth';
                            }
                            return null;
                          },
                          onTap: () {
                            selectYear(context);
                            // DateTime? pickedDate = await showDatePicker(
                            //     context: context,
                            //     initialDate: DateTime.now(),
                            //     firstDate: DateTime(
                            //         1950), //DateTime.now() - not to allow to choose before today.
                            //     lastDate: DateTime.now());

                            // if (pickedDate != null) {
                            //   String formattedDate =
                            //       DateFormat('yyyy-MM-dd').format(pickedDate);
                              

                            //   setState(() {
                            //     dateinput.text =
                            //         formattedDate; //set output date to TextField value.
                            //   });
                            // } else {
                            //   print("Date is not selected");
                            // }


                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(15),
                        child: TextFormField(
                          controller: emailAddress,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email Address',
                              hintText: 'Email Address'),
                          // validator: (value) {
                          //   if (value == null ||
                          //       value.isEmpty ||
                          //       !value.contains("@")) {
                          //     return 'Please enter valid email address';
                          //   }
                          //   return null;
                          // },
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
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: gender.map((item) {
                            return DropdownMenuItem(
                                value: item.value, child: item.child);
                          }).toList(),
                          onChanged: handleGenderVal,
                          hint: const Text("Select Gender"),
                          value: selectedGender,
                          validator: (value) =>
                              value == null ? 'Please select a Gender' : null,
                        )
                        // child: TextFormField(
                        //   controller: gender,
                        //   decoration: const InputDecoration(
                        //       border: OutlineInputBorder(),
                        //       labelText: 'Gender',
                        //       hintText: 'Gender'),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter Gender';
                        //     }
                        //     return null;
                        //   },
                        // )
                        ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                        child: Row(
                          children: [
                            Checkbox(
                              value: smsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  smsEnabled = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text("SMS Enabled")
                          ],
                        )),
                    isLoading
                        ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextButton(
                                onPressed: () => callAddPatient(),
                                child: const Text(
                                  'Submit',
                                  textAlign: TextAlign.center,
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
