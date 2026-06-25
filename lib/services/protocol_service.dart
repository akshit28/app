import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/constants/constants.dart';
import 'package:aap/models/testscanlist_model.dart';
import "package:aap/models/error_model.dart";

class ProtocolService{
  var sharedIns = SharedPref();

  Future fetchTestScans(payload) async{
    final TestScanList data;
    final String userToken = await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.testScanList);

      var response  = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authentication': userToken,  
      },body: jsonEncode(<String, dynamic>{
        'device_id': payload['deviceId'].toString(),
        'end_date': payload['endDate'],
        'mobile_number':payload['mobileNumber'].toString(),
        'page_num':payload['pageNum'],
        'row_count':payload['rowCount'],
        'start_date':payload['startDate'],
      }));

      if(response.statusCode == 200){
        var resp = json.decode(response.body);
        if(resp["success"]){
          data = TestScanList.fromJson(json.decode(response.body));
          return data;
        }else{
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      }else{
        // throw Exception("Something went wrong");
        print("Something went wrong");
      }

    } catch (e) {
      // throw Exception("Error Code : ${e.toString()}");
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchUpdatedSample(payload) async{
    final data;
    final String userToken = await sharedIns.getValueFromSharedPreferences("userToken") as String;
    
    var jsonString = {
        "device_id": payload['deviceId'],
        "end_date": payload['endDate'],
        "mobile_number":payload['mobileNumber'],
        "page_num":payload['pageNum'],
        "row_count":payload['rowCount'],
        "start_date":payload['startDate'],
        "sample_id": payload['sampleId'].replaceAll('"', '')
      };
    

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.testScanList);

      var response  = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authentication': userToken,  
      },body: jsonEncode(jsonString));

      if(response.statusCode == 200){
        // data = Row.fromJson(json.decode(response.body));
        data = json.decode(response.body);
        print("fetchUpdatedSample ****");
        return data;
      }else{
        throw Exception("Something went wrong");
      }
      
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }



  Future cancelScan(String payload) async{
    final data;
    final String userToken = await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.cancelScan);

       var response  = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authentication': userToken,  
      },body: jsonEncode(<String, String>{
        "internal_sample_code": payload
      }));

      if(response.statusCode == 200){
        data = jsonDecode(response.body);
        return data['success'];
      }
      
    } catch (e) {
      // throw Exception("Error Code : ${e.toString()}");
      print("Error Code : ${e.toString()}");
    }
  }

  Future continueScan(String payload) async{
    final data;
    final String userToken = await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.continueScan);

       var response  = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authentication': userToken,  
      },body: jsonEncode(<String, String>{
        "internal_sample_code": payload
      }));

      if(response.statusCode == 200){
        data = jsonDecode(response.body);
        return data['success'];
      }
      
    } catch (e) {
      // throw Exception("Error Code : ${e.toString()}");
      print("Error Code : ${e.toString()}");
    }
  }

}