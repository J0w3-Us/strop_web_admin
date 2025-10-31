import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strop_admin_panel/core/state/data_state.dart';
import 'package:strop_admin_panel/domain/auth/auth_repository.dart';
// fpdart and failures are used in repository; not required directly here

class AuthProvider extends ChangeNotifier {
  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  // Simple user payload placeholder
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  DataState state = DataState.initial;
  String? errorMessage;

  /// Load token from storage on startup
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      _authenticated = true;
      // Optionally load user info if stored
      final userEmail = prefs.getString('auth_user_email');
      if (userEmail != null) _user = {'email': userEmail};
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    state = DataState.loading;
    errorMessage = null;
    notifyListeners();

    final res = await AuthRepository.instance.login(email, password);
    bool ok = false;

    // Use fold to handle left/failure and right/success
    res.fold(
      (failure) {
        errorMessage = failure.message;
        state = DataState.error;
        ok = false;
      },
      (data) {
        final token = data['token']?.toString();
        final user = data['user'] as Map<String, dynamic>?;
        if (token != null) {
          // update runtime state immediately
          _authenticated = true;
          _user = user ?? {'email': email};
          state = DataState.success;
          ok = true;

          // persist token asynchronously (fire-and-forget)
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('auth_token', token);
            if (user != null && user['email'] != null) {
              prefs.setString('auth_user_email', user['email'].toString());
            }
          });
        } else {
          errorMessage = 'No token returned';
          state = DataState.error;
          ok = false;
        }
      },
    );

    notifyListeners();
    return ok;
  }

  /// Test helper: directly set authentication state for unit/widget tests.
  /// Use only in tests to avoid relying on SharedPreferences or network.
  @visibleForTesting
  void setAuthenticatedForTest({required Map<String, dynamic> user}) {
    _authenticated = true;
    _user = user;
    state = DataState.success;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_email');
    _authenticated = false;
    _user = null;
    state = DataState.initial;
    notifyListeners();
  }
}
