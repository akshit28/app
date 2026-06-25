import 'dart:convert';
import "dart:developer";

import 'package:http/http.dart' as http;
import 'package:piiko_app/constants/constants.dart';
import 'package:piiko_app/models/scan_model.dart';


class ScanService{
  Future<ScanModel?> searchPatient(String patientnum) async{
    final ScanModel data;
    String token = '66c093765cb479915757518c59d071399b43f727';
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.patientList);
      var response  = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authentication': token 
    },body: jsonEncode(<String, String>{
      'mobile_number': patientnum,
      'patient_id': ""
    }));

    if(response.statusCode == 200){
      data = ScanModel.fromJson(json.decode(response.body));

      print("Success");
      print(data);
      return data;
    }else{
      throw Exception("Something went wrong");
    }

    } catch(e){
      throw Exception("Error Code : ${e.toString()}");
    }
  }
}