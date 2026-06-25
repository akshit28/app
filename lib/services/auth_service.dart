
import 'dart:convert';
import "dart:developer";

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:piiko_app/constants/constants.dart';
import 'package:piiko_app/models/user_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthService{
 
  Future<UserModel?> login(String email, String password) async {
    final UserModel data;

    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      var response  = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, String>{
      'user_name': email,
      'password': password
    }));

      if(response.statusCode == 200){
        
        data = UserModel.fromJson(json.decode(response.body));
        print("Success");
        print(data.success);
        return data;

      }else{
        throw Exception("Something went wrong");
      }
    } catch(e){
      // setloading(false);
      // await EasyLoading.showError(
      //     "Error Code : ${e.toString()}");
          throw Exception("Error Code : ${e.toString()}");
      // return null;
    }
  }
}