import 'package:flutter/material.dart';

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