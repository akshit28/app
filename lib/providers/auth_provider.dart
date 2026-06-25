import 'package:flutter/foundation.dart';
import 'package:piiko_app/models/user_model.dart';
import 'package:piiko_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _service = AuthService();
  bool isLoading = false;
  bool _isloggedin = false;
  String _userToken = "";
  UserModel? _data;
  
  UserModel? get userData => _data;
  get loginSuccess => _isloggedin;
  get userToken => _userToken;

   Future<void> fireLogin(username, password) async {
    isLoading = true;
    notifyListeners();

    final response = await _service.login(username, password);
    
    _data = response!;
    _isloggedin = _data!.success;
    _userToken = _data!.data.token;
    // notifyListeners();
    
    isLoading = false;
    notifyListeners();
  }
}