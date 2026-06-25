import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aap/constants/constants.dart';
import 'package:aap/models/user_model.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/error_model.dart';
import 'package:aap/models/tokenVerification_model.dart';
import 'package:aap/models/menuitem_modal.dart';

class AuthService {
  var sharedIns = SharedPref();

  Future login(String email, String password) async {
    final UserModel data;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{'user_name': email, 'password': password}));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = UserModel.fromJson(json.decode(response.body));
          await sharedIns.saveValueToSharedPreferences(
              'userToken', data.data.token);
          await sharedIns.saveValueToSharedPreferences(
              'userId', data.data.additionalInfo.userId.toString());
          await sharedIns.saveValueToSharedPreferences(
            'username', data.data.additionalInfo.username.toString()
          );
          await sharedIns.saveValueToSharedPreferences(
            'organization', data.data.additionalInfo.organizations[data.data.additionalInfo.organizations.length-1].name.toString()
          );
          
          List<String> encodedList = data.data.additionalInfo.facilities.map((item) => jsonEncode(item.toJson())).toList();
          await sharedIns.saveValueAsStringList('orgList', encodedList);


          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        //throw Exception("Something went wrong");
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future saveFcmToken() async {
    final data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    final dynamic fcmToken =
        await sharedIns.getValueFromSharedPreferences("fcmToken");
    final String permissionStatus = await sharedIns
        .getValueFromSharedPreferences("pushPermissionStatus") as String;
    print("fcmToken ***: $fcmToken");
    if(fcmToken == null){
      return;
    }

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "token": fcmToken,
            "metadata": [
              {
                "name": "android.permission.push_notification",
                "label": "push_notification",
                "status": permissionStatus
              }
            ],
            "user_token": userToken,
            "forwarder_endpoint": "/custom/device-token/upsert",
            "forwarder_type": "MASTER"
          }));

      if (response.statusCode == 200) {
        print("FCM registered *****");
        // var resp = json.decode(response.body);
        // print(resp);
      } else {}
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future verifyToken() async {
    final TokenVerificationModel data;
    print("verifyToken called ******");
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyToken);
      var response = await http.post(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authentication': userToken,
      });
      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = TokenVerificationModel.fromJson(json.decode(response.body));
          await sharedIns.saveValueToSharedPreferences(
              'userId', data.data.userId.toString());

          await sharedIns.saveValueToSharedPreferences(
          'facilityId', data.data.facilities[0].id);
          await sharedIns.saveValueToSharedPreferences(
            'username', data.data.username.toString()
          );

          await sharedIns.saveValueToSharedPreferences(
            'organization', data.data.organizations[data.data.organizations.length-1].name.toString()
          );

          List<String> encodedList = data.data.facilities.map((item) => jsonEncode(item.toJson())).toList();
          await sharedIns.saveValueAsStringList('orgList', encodedList);

        }
      } else {
        
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchMenu() async {
    final MenuItems data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
        final String userId =
        await sharedIns.getValueFromSharedPreferences("userId") as String;

        try {
          var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forwarder);
          var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
            'X-Piiko-Userid': userId
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/custom/menu-item/get",
            "forwarder_type": "MASTER",
            // "status": "ACTIVE",
            // "type": "CUSTOMER"
          }));

          if (response.statusCode == 200) {
            var resp = json.decode(response.body);
            if (resp["success"]) {
              data = MenuItems.fromJson(json.decode(response.body));
              return data;
            }else{
              final apiError = ErrorModel.fromJson(json.decode(response.body));
              return apiError;
            }
          }else{

          }

        } catch (e) {
          print("Error Code : ${e.toString()}");
        }

  }
}
