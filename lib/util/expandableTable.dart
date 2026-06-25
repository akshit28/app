import 'package:flutter/material.dart';

class ExpandableTable extends StatefulWidget {
  final List items;
  const ExpandableTable({super.key, required this.items});

  @override
  State<ExpandableTable> createState() => _ExpandableTableState();
}

class _ExpandableTableState extends State<ExpandableTable> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}