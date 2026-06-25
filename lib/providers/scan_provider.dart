import 'package:flutter/foundation.dart';
import 'package:aap/models/scan_model.dart';
import 'package:aap/services/scan_service.dart';
// import 'package:aap/models/facility_model.dart';

class ScanListProvider extends ChangeNotifier{
  final _service = ScanService();
  List<Row> _item = [];
  bool isLoading = false;
  // List<Facility> _facilities = [];
  // ScanModel? _data;
  List<Row> get itemsList => _item;
  // get loading => isLoading;
  // List<Facility> get facilityList => _facilities;

  Future<void> findPatient(patientnum) async {
    // isLoading = true;
    _item = [];
    final response = await _service.searchPatient(patientnum);
    // isLoading = false;
    if(response != null){
      _item = response.data.rows;
    }else{

    }
    
    notifyListeners();
  }

}