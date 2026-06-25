import 'package:flutter/foundation.dart';
import 'package:aap/services/protocol_service.dart';
import 'package:aap/models/testscanlist_model.dart';
// import "package:aap/models/protocolupdate_model.dart" as prtocol;
import 'package:intl/intl.dart';
import 'dart:convert';

class ProtocolProvider extends ChangeNotifier {
  final _service = ProtocolService();

  final List _item = [];
  int rowCount = 0;
  bool isLoading = false;
  DateTime lastRefreshed = DateTime.now();

  List get protocolList => _item;
  int get totalRows => rowCount;
  DateTime get lastUpdated => lastRefreshed;

  Future getProtocolList(payload) async {
    late TestScanList response;
    isLoading = true;

    // TestScanList response = await _service.fetchTestScans(payload);
    var data = await _service.fetchTestScans(payload);
    if(data.success){
       response = data;
       _item.addAll(response.data.rows);
       rowCount = response.data.rowCount;
    }else{
      _item.addAll([]);
    }

    isLoading = false;
    
    
    // lastRefreshed = DateTime.now();
    notifyListeners();
    if(data.success){
      return response;
    }else{
      return data;
    }
    
  }

  Future<void> updateProtocols(payload) async {
    isLoading = true;
    
    final responseRes = json.decode(payload)['sample_data'];
    final response = Row.fromJson(json.decode(payload)['sample_data']["data"]["rows"][0]);
    isLoading = false;
    if (responseRes["success"]) {
      lastRefreshed = DateTime.now();
      if(_item.isEmpty) return;
      int index = _item.indexWhere((element) =>
          element.sampleId == response.sampleId);
      if (index != -1) {       
        _item[index] = response;
        print('Row UPdated ${response.internalSampleId}--${response.isAudible}--${response.showTimer}--${response.inSleep}');
        print('Current action data ${_item[index].action}');
        print('Current index $index');
        print('Updated actions ---- ${response.action}');
        print("timer val ${response.sleepStarted} -- ${response.waitingPeriod}");
        print("Instructions: ${response.instructions}");
      } else {
        print(
              "INternal Sample Id not found ${response.internalSampleId}--${response.deviceName}");
        var newScanDate =
            DateTime.parse(response.sampleRequestedAt);
        var firstScanDate = DateTime.parse(_item[0].sampleRequestedAt);

        if (firstScanDate.isBefore(newScanDate) || firstScanDate.isAtSameMomentAs(newScanDate)) {
          print(
              "INternal Sample Id not found ${response.internalSampleId}");
          _item.insert(0, response);
        }
      }
      notifyListeners();
    }
  }

  Future<void> updateProtocolAction(String internalSampleId) async{
    print("updateProtocolAction called *********************************");
    int index = _item.indexWhere((element) => element.internalSampleId == internalSampleId);
    if(index != -1){
      _item[index].action.remove('CONTINUE');
      _item[index].instructions.clear();
    }
    print(_item[index].internalSampleId);
    print(_item[index].action);
    notifyListeners();
  }

  Future<void> removeInstruction(String internalSampleId) async{
    print("removeInstruction called ******");
    int index = _item.indexWhere((element) => element.internalSampleId == internalSampleId);
    if(index != -1){
      _item[index].instructions.clear();
    }
    notifyListeners();
  }

  Future<void> addContinueButton(String internalSampleId) async{
    print("addContinueButton called ******");
    int index = _item.indexWhere((element) => element.internalSampleId == internalSampleId);
    if(index != -1){
      _item[index].action.add('CONTINUE');
      print(_item[index].action);
    }
    notifyListeners();
  }
}
