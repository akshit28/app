import 'package:flutter/foundation.dart';
import 'package:piiko_app/models/scan_model.dart';
import 'package:piiko_app/services/scan_service.dart';

class ScanListProvider extends ChangeNotifier{
  final _service = ScanService();
  ScanModel? _data;

  Future<void> findPatient(patientnum) async {
    final response = await _service.searchPatient(patientnum);

    _data = response!;
  }

}