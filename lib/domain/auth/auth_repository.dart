import 'package:strop_admin_panel/core/services/api_client.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  bool _useApi = false;

  void enableApi(bool v) => _useApi = v;

  // Hardcoded demo account
  static const demoEmail = 'test@local';
  static const demoPassword = '1234';

  Future<bool> login(String email, String password) async {
    if (_useApi) {
      final res = await ApiClient.instance.post('/auth/login', {
        'email': email,
        'password': password,
      }, (d) => d as Map);
      return res['ok'] == true;
    }
    // Local simulated auth
    await Future.delayed(const Duration(milliseconds: 200));
    return email == demoEmail && password == demoPassword;
  }
}
