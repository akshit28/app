import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aap/constants/constants.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/error_model.dart';

class ReportService{
  var sharedIns = SharedPref();
  Future consolidateReports(List sampleIds) async{
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/sample-report/?link-update=false",
            "forwarder_type": "REPORT",
            "data_source": "SERVER",
            "sample_ids": sampleIds
          }));

          if (response.statusCode == 200) {
            var resp  = jsonDecode(response.body);
            if (resp["success"]) {
              return resp["success"];
            }else{
              final apiError = ErrorModel.fromJson(json.decode(response.body));
              return apiError;
            }
          }else{
            final apiError = ErrorModel.fromJson(json.decode(response.body));
            return apiError;
          }
          
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }
}