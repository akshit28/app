import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:aap/providers/scan_provider.dart";
import 'package:intl/intl.dart';

class SearchPatient extends StatefulWidget {
  const SearchPatient({super.key});

  @override
  State<SearchPatient> createState() => _SearchPatientState();
}

class _SearchPatientState extends State<SearchPatient> {
  final searchController = TextEditingController();
  bool loading = false;

  void clearText() {
    searchController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanListProvider>(context);
    final List item = context.watch<ScanListProvider>().itemsList;

    fireSearch(val) {
      if (val.length >= 10) {
        // EasyLoading.isShow
        setState(() {
          loading = true;
        });
        scanProvider.findPatient(val);
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Search Patient"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              // autofocus: true,
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
          Padding(
            padding: const EdgeInsets.all(15),
            child: item.isEmpty ? const Center(child: Text("No Patient Found."),) : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: item.length,
                itemBuilder: (context, index) {
                  print("List View called *****");
                  print(item);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                                        const Icon(
                                            Icons.person_outline_outlined),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 10, 0),
                                          child: Text(
                                              '${item[index].name} / ${item[index].gender}'),
                                        )
                                      ],
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 0, 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.phone_outlined),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 10, 0),
                                              // child: Text(item[index].dateOfBirth.toString())),
                                              child: Text(item[index].mobile)),
                                        ])),
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.cake_outlined),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 10, 0),
                                              child: Text(DateFormat.yMMMMd()
                                                  .format(item[index]
                                                      .dateOfBirth))),
                                        ])),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/add_patient',
                                              // arguments: item[index].patientId
                                              // MaterialPageRoute(builder: (context) => ScanForm(patientId: item[index].patientId)),
                                              );
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Book Test',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/scan_form',
                                              arguments: item[index].patientId
                                              // MaterialPageRoute(builder: (context) => ScanForm(patientId: item[index].patientId)),
                                              );
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
          )
        ],
      )),
    );
  }
}