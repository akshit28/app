import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref{
  
  Future<void> saveValueToSharedPreferences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('Value saved to shared preferences $key');
  }

  Future<void> saveValueAsStringList(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> stringList = value.map((item) => item.toString()).toList();
    //  List<String> jsonStringList = value.map((obj) {
    //   return jsonEncode(obj.toMap());
    // }).toList();
    await prefs.setStringList(key, value);
    print('Value saved to shared preferences $key');
  }

  Future getValueAsStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.getStringList(key);
    return prefs.getStringList(key) ?? [];
    // print('Value saved to shared preferences $key');
  }
  

  Future<String?> getValueFromSharedPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    return value;
  }

  Future<bool> isLoggedIn(bool bool) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    print('Shared Pref cleared *****');
  }
}