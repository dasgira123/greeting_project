import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AuthViewModel(this._repository) {
    _loadUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _repository.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAuth() async {
    await _loadUser();
  }

  Future<bool> updateProfile(String fullName, String? dob) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _repository.updateProfile(_currentUser!.id, fullName, dob);
      if (user != null) {
        _currentUser = user;
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

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _repository.updatePassword(_currentUser!.id, oldPassword, newPassword);
      if (user != null) {
        _currentUser = user;
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

  Future<bool> updateAvatar(String avatarPath) async {
    if (_currentUser == null) return false;
    try {
      final user = await _repository.updateAvatar(_currentUser!.id, avatarPath);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    } catch (e) {
      //
    }
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }
}
