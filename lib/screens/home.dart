import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import "package:aap/providers/scan_provider.dart";
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final searchController = TextEditingController();

  void clearText() {
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanListProvider>(context);
    final List item = context.watch<ScanListProvider>().itemsList;
    // final bool isLoading = context.watch<ScanListProvider>().loading;
    bool loading = false;

    fireSearch(val) {
      if (val.length >= 10) {
        scanProvider.findPatient(val);
        setState(() {
          loading = true;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Patient Dashboard"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: searchController,
              onChanged: (input) => fireSearch(input),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                labelText: 'Search Patient',
                hintText: 'Enter Mobile no.',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearText,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 10, 15, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text("Patient List",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.left)
            ]),
          ),
          item.isEmpty && loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: item.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 7),
                          child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 0, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(Icons
                                                  .person_outline_outlined),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 10, 0),
                                                child: Text(
                                                    '${item[index].name} / ${item[index].gender}'),
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 0, 10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                    Icons.phone_outlined),
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(20, 0, 10, 0),
                                                    // child: Text(item[index].dateOfBirth.toString())),
                                                    child: Text(
                                                        item[index].mobile)),
                                              ])),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 0, 0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.cake_outlined),
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(20, 0, 10, 0),
                                                    child: Text(
                                                        DateFormat.yMMMMd()
                                                            .format(item[index]
                                                                .dateOfBirth))),
                                              ])),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // TextButton(
                                            //   child: const Text(
                                            //     'Edit',
                                            //     style: TextStyle(fontSize: 18),
                                            //   ),
                                            //   onPressed: () {
                                            //     AddPatients patient = AddPatients(patientId: item[index].patientId, mobNum: item[index].mobile, gender: item[index].gender, dob: item[index].dateOfBirth.toString(), smsenabled: item[index].isSmsEnabled, email: item[index].email);
                                            //     print(patient.toJson());
                                            //     Navigator.pushNamed(
                                            //         context, '/add_patient',
                                            //         // arguments: {"patientId": item[index].patientId, "mobNum": item[index].mobile, "gender": item[index].gender, "dob": item[index].dateOfBirth.toString(), "smsenabled": item[index].isSmsEnabled, "email": item[index].email}
                                            //         // arguments: patient.toJson()
                                            //         // arguments: Add
                                            //         // MaterialPageRoute(builder: (context) => ScanForm(patientId: item[index].patientId)),
                                            //         );
                                            //   },
                                            // ),
                                            TextButton(
                                              child: const Text(
                                                'Book Test',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/scan_form',
                                                    arguments: {
                                                      'patientId': item[index].patientId,
                                                      'patientName': item[index].name
                                                    });
                                              },
                                            ),
                                            // const SizedBox(width: 8),
                                          ],
                                        ),
                                      )
                                    ],
                                  ))),
                        );
                      }),
                ),
        ],
      ),
    );
  }
}

class AddPatients {
  final String patientId;
  final String mobNum;
  final String gender;
  final String dob;
  final String smsenabled;
  final String email;

  AddPatients({
    required this.patientId,
    required this.mobNum,
    required this.gender,
    required this.dob,
    required this.smsenabled,
    required this.email,
  });

  factory AddPatients.fromJson(Map<String, dynamic> json) => AddPatients(
        patientId: json["patientId"],
        mobNum: json["mobNum"],
        gender: json["gender"],
        dob: json["dob"],
        smsenabled: json["smsenabled"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "patientId": patientId,
        "mobNum": mobNum,
        "gender": gender,
        "dob": dob,
        "smsenabled": smsenabled,
        "email": email,
      };
}
