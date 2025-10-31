import 'package:flutter/foundation.dart';
import 'package:strop_admin_panel/domain/auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  // Simple user payload placeholder
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  Future<bool> login(String email, String password) async {
    final ok = await AuthRepository.instance.login(email, password);
    if (ok) {
      _authenticated = true;
      _user = {'email': email};
      notifyListeners();
    }
    return ok;
  }

  void logout() {
    _authenticated = false;
    _user = null;
    notifyListeners();
  }
}
