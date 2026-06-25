import 'package:flutter/foundation.dart';
import 'package:aap/models/user_model.dart';
import 'package:aap/services/auth_service.dart';
import 'package:aap/providers/shared_pref.dart';

class AuthProvider with ChangeNotifier {
  final _service = AuthService();
  var sharedIns = SharedPref();
  bool isLoading = false;
  bool _isloggedin = false;
  String _userToken = "";
  UserModel? _data;
  
  
  UserModel? get userData => _data;
  get loginSuccess => _isloggedin;
  get userToken => _userToken;
  get loading => isLoading;

   Future<dynamic> fireLogin(username, password) async {
    isLoading = true;
    notifyListeners();
    String? loggedToken = await sharedIns.getValueFromSharedPreferences("userToken");
    _userToken = loggedToken ?? '';
    final response = await _service.login(username, password);
    
    if(response.success){
      _data = response!;
      _isloggedin = _data!.success;
    }else{
      _isloggedin = false;
    }
    isLoading = false;
    notifyListeners();
    return response;
  }
}