import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aap/constants/constants.dart';
import 'package:aap/models/commandhistory_model.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/command_model.dart';
import 'package:aap/models/error_model.dart';
import 'package:aap/models/commandqueue_model.dart';

class CommandService {
  var sharedIns = SharedPref();

  Future commandsList(Map payload) async {
    final CommandHistoryModal data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.commandHistory);

    try {
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "device_id": payload['deviceId'],
            'end_date': payload['endDate'],
            'page_num':payload['pageNum'],
            'row_count':payload['rowCount'],
            'start_date':payload['startDate']
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = CommandHistoryModal.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchCommands(String masterDeviceId) async {
    final CommandModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.commands);
    try {
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "master_device_id": masterDeviceId,
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = CommandModel.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future queueNewCommand(Map payload) async {
    // final CommandQueueModal data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.commandQueue);
    print({
      "device_code": payload["device_code"],
      "master_device_id": payload["master_device_id"],
      "facility_id": payload["facility_id"],
      "device_command_id": payload["device_command_id"],
      "command_pay_load": payload["command_pay_load"]
    });
    try {
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "device_code": payload["device_code"],
            "master_device_id": payload["master_device_id"],
            "facility_id": payload["facility_id"],
            "device_command_id": payload["device_command_id"],
            "command_pay_load": payload["command_pay_load"]
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          // final data = CommandQueueModal.fromJson(json.decode(response.body));
          // final data = json.decode(response.body);
          return resp;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future cancelCommand(String deviceCommandId) async{
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.commandCancel);

    try {
       var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "device_command_id": deviceCommandId,
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
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
