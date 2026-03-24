import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  LoginViewModel(this._repository);

  String _phone = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  String get phone => _phone;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isPasswordVisible => _isPasswordVisible;

  void setPhone(String val) {
    _phone = val;
    notifyListeners();
  }

  void setPassword(String val) {
    _password = val;
    notifyListeners();
  }

  void toggleRememberMe(bool? val) {
    _rememberMe = val ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_phone.isEmpty || _password.isEmpty) {
      _errorMessage = 'Vui lòng nhập số điện thoại và mật khẩu';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(_phone, _password);
      if (user != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
