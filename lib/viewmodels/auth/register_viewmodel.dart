import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  RegisterViewModel(this._repository);

  String _fullName = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';
  String? _dob;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String get fullName => _fullName;
  String get phone => _phone;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String? get dob => _dob;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void setFullName(String val) { _fullName = val; notifyListeners(); }
  void setPhone(String val) { _phone = val; notifyListeners(); }
  void setPassword(String val) { _password = val; notifyListeners(); }
  void setConfirmPassword(String val) { _confirmPassword = val; notifyListeners(); }
  void setDob(String? val) { _dob = val; notifyListeners(); }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<bool> checkBeforeOtp() async {
    if (_fullName.isEmpty || _phone.isEmpty || _password.isEmpty || _dob == null) {
      _errorMessage = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }
    if (_password != _confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exists = await _repository.checkPhoneExists(_phone);
      if (exists) {
        _errorMessage = 'Số điện thoại đã được đăng ký!';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register() async {
    if (_fullName.isEmpty || _phone.isEmpty || _password.isEmpty) {
      _errorMessage = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }
    if (_password != _confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.register(fullName: _fullName, phone: _phone, password: _password, dob: _dob);
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
