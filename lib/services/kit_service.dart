import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aap/constants/constants.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/kitinvalid_model.dart';
import 'package:aap/models/error_model.dart';
import 'package:aap/models/kitcodedetails_model.dart';
import 'package:aap/models/kitstatus_model.dart';
import 'package:aap/models/kitdetails_model.dart';
// import 'package:aap/models/kitbatch_model.dart';
import 'package:aap/models/assignedkit_model.dart';

class KitService {
  var sharedIns = SharedPref();

  Future fetchKitDetails(String type, String kitCode) async {
    final KitCodeDetailsModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    final String userId =
        await sharedIns.getValueFromSharedPreferences("userId") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "type": type,
            "code": kitCode,
            "forwarder_endpoint": "/custom/qr-code/get",
            "forwarder_type": "MASTER",
            "user_id": int.parse(userId)
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = KitCodeDetailsModel.fromJson(json.decode(response.body));
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

  Future getKitDeatils(String kitCode) async {
    final KitDeatilsModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/kit/get",
            "forwarder_type": "MASTER",
            "code": kitCode
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = KitDeatilsModel.fromJson(json.decode(response.body));
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

  Future fetchKitInvalidReasons() async {
    final KitInvalidModel data;
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
            "forwarder_endpoint": "/kit-rejection-reason/get",
            "forwarder_type": "MASTER",
            "status": "ACTIVE",
            "type": "CUSTOMER"
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = KitInvalidModel.fromJson(json.decode(response.body));
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

  Future fetchKitStatuses() async {
    final KitStatus data;
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
            "forwarder_endpoint": "/kit-status/get",
            "status": "ACTIVE",
            "forwarder_type": "MASTER",
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = KitStatus.fromJson(json.decode(response.body));
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

  Future submitKitDamage(Map payload) async {
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    // final String facilityId =
    //     await sharedIns.getValueFromSharedPreferences("facilityId") as String;
    // String environment =
    //     ApiConstants.baseUrl.contains("cytocloud") ? "Production" : "Staging";
    // print(jsonEncode(<String, dynamic>{
    //         "forwarder_endpoint": "/kit/upsert",
    //         "forwarder_type": "MASTER",
    //         "id": payload["id"],
    //         "facility": payload["newfacility"],
    //         "kit_rejection_reason": payload["kitRejectionReason"],
    //         "status": payload["kitUpdatedStatus"]
    //       }));
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forwarder);

      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/kit/upsert",
            "forwarder_type": "MASTER",
            "id": payload["id"],
            "facility": payload["newfacility"],
            "kit_rejection_reason": payload["kitRejectionReason"],
            "status": payload["kitUpdatedStatus"]
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);

        if (resp["success"]) {
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

  Future kitStatusBatchUpload(payload) async {
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
            "forwarder_endpoint": "/custom/kit/bulk-update?debug=false",
            "forwarder_type": "MASTER",
            "data": payload
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          return resp;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {}
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchAssignedKit(String facility) async {
    final AssignedKit data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "forwarder_endpoint": "/kit/get",
            "forwarder_type": "MASTER",
            "status__code": "AVAILABLE",
            "expiry_date__gte": "",
            "facility": facility
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = AssignedKit.fromJson(json.decode(response.body));
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

  Future markKitInUse(String facility, String id, String status) async {
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "forwarder_endpoint": "/kit/upsert",
            "forwarder_type": "MASTER",
            "facility": facility,
            "id": id,
            "status": status
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          return resp["success"];
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {}
  }
}
