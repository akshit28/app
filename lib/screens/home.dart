import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:piiko_app/providers/scan_provider.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanListProvider>(context);
    _fireSearch(val){
      if(val.length >= 10){
        scanProvider.findPatient(val);
      }
    }
    return Scaffold(
       appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.blue,
          title: const Text("Patient Dashboard"),
          // iconTheme: const IconThemeData(color: Colors.white),
          // leading: IconButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   icon: const Icon(
          //     Icons.arrow_back,
          //   ),
          // ),
        ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: searchController,
                onChanged: (input) => _fireSearch(input),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    fillColor: Colors.white,
                    labelText: 'Search Patient',
                    hintText: 'Enter Mobile no.'),
              ),
            ),
          ],
        )
      ),
    );
  }
}