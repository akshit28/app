import 'package:flutter/material.dart';
import 'package:aap/screens/accounts/statement.dart';
import 'package:aap/screens/accounts/credit_note.dart';
import 'package:aap/screens/accounts/payments.dart';
import 'package:aap/screens/accounts/ledger.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, 
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.blue,
          title: const Text("Accounts"),
          bottom: const TabBar(
              tabs: [
                // Tab(text: "Statement"),
                Tab(text: "Invoices"),
                Tab(text: "Credit Note"),
                Tab(text: "Payments"),
              ]
            ),
        ),
        body: const TabBarView(
          children: [
            // AccountLedger(),
            AccountStatement(),
            CreditNote(),
            Payments(),
          ]
          ),
      )
    );
  }
}