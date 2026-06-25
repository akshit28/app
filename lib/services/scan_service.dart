import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aap/constants/constants.dart';
import 'package:aap/models/scan_model.dart';
import 'package:aap/models/facility_model.dart';
import 'package:aap/models/device_model.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/test_model.dart';
import 'package:aap/models/testlist_model.dart';
import 'package:aap/models/scanqueue_model.dart';
import 'package:aap/models/scanpayload_model.dart';
import 'package:aap/models/addpatient_model.dart';
import 'package:aap/models/error_model.dart';
import 'package:aap/models/deviceInfo_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ScanService {
  var sharedIns = SharedPref();
  final jsonEncoder = const JsonEncoder();

  Future<ScanModel?> searchPatient(String patientnum) async {
    final ScanModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.patientList);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(
              <String, String>{'mobile_number': patientnum, 'patient_id': ""}));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = ScanModel.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          // return apiError;
        }

        // print("searchPatient");
        // print(data);
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future<FacilityModel> getFacility() async {
    final FacilityModel data;

    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.userFacilities);
      var response = await http.post(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authentication': userToken,
      });

      if (response.statusCode == 200) {
        data = FacilityModel.fromJson(json.decode(response.body));
        // print("getFacility");
        // print(data.data.facilities);
        return data;
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future getDevices(String facilityId) async {
    final DeviceModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.deviceList);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            'facility_id': facilityId,
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"] && resp["data"] != null) {
          data = DeviceModel.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future<TestModel> getTestGroup(
      String facilityId, String masterDeviceId) async {
    final TestModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.testGroups);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            'facility_id': facilityId,
            'master_device_id': masterDeviceId,
          }));

      if (response.statusCode == 200) {
        data = TestModel.fromJson(json.decode(response.body));
        return data;
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future<TestListModel> getTestList(
      String deviceSerial, String testGroupId) async {
    final TestListModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.testList);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            'device_serial': deviceSerial,
            'test_group_id': testGroupId,
          }));

      if (response.statusCode == 200) {
        data = TestListModel.fromJson(json.decode(response.body));
        return data;
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future setScanQueue(ScanPayload payload) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final ScanQueueModel data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.newScanQueue);
      String environment = ApiConstants.baseUrl.contains("cytocloud") ? "Production" : "Staging";
      String version = packageInfo.version;
      // String deviceModal = packageInfo.mode
      DeviceInfo deviceInfo = DeviceInfo(origin: "mobile_app", clientType: "android", version: version, environment: environment);

      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authentication': userToken,
          },
          body: jsonEncode({
            "facility_id": payload.facilityId,
            "device_code": payload.deviceCode,
            "test_group_id": payload.testGroupId,
            "external_patient_code": "",
            "external_sample_code": payload.externalSampleCode,
            "patient_id": payload.patientId,
            "kit_code": payload.kitCode,
            "batch_type": payload.batchType,
            "test_chamber_number": payload.testChamberNumber,
            "tracking_info": deviceInfoToJson(deviceInfo)
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = ScanQueueModel.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        print("ERROR CODE");
        print(response.statusCode);
        throw Exception("Something went wrong");
      }
    } catch (e) {
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future addNewPatient(Map payload) async {
    final AddPatientModel data;

    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.addPatient);

      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "patient_id": payload['patientId'],
            "name": payload["name"],
            "mobile_number": payload["mobile"],
            "email_address": payload["email"],
            "date_of_birth": payload["dob"],
            "gender": payload["gender"],
            "is_sms_enabled": payload["sms"]
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = AddPatientModel.fromJson(json.decode(response.body));
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
      throw Exception("Error Code : ${e.toString()}");
    }
  }

  Future validateKit(Map payload) async {
    final data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.kitValdation);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "facility_id": payload['facilityId'],
            "test_group_id": payload['testGroupId'],
            "kit_code": payload['kitCode']
          }));

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        return data["success"];
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future getDefaultTestGroup(String deviceId) async{
    final data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    final String facilityId =
        await sharedIns.getValueFromSharedPreferences("facilityId") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, String>{
            "forwarder_endpoint": "/device/get",
            "forwarder_type": "MASTER",
            "id": facilityId
          }));

          if (response.statusCode == 200) {
            var resp  = jsonDecode(response.body);
            if (resp["success"]) {
              print(resp["data"][0]["test_group"]);
              // if(resp["data"][0]["test_group"] == null){
              //   await sharedIns.saveValueToSharedPreferences('defaultTestGroup', "");
              // }else{
                await sharedIns.saveValueToSharedPreferences('defaultTestGroup', resp["data"][0]["test_group"] ?? "");
              // }
              return resp["data"][0]["test_group"];
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

  Future setDefaultTestGroup(String deviceId, String testGroupId) async{
    final data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },

          body: jsonEncode(<String, String>{
            "forwarder_endpoint": "/device/upsert",
            "forwarder_type": "MASTER",
            "id": deviceId,
            "default_test_group": testGroupId
            // "id": "ed68ebfc-de21-4cc7-a0f8-fc524615bec5",
	          // "default_test_group": "47e94452-a09e-4dd3-9447-dbe855ccb50a"
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
