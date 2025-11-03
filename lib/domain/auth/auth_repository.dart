import 'package:fpdart/fpdart.dart';
import 'package:strop_admin_panel/core/services/api_client.dart';
import 'package:strop_admin_panel/domain/failures.dart';
import 'package:strop_admin_panel/domain/exceptions.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  bool _useApi = false;

  void enableApi(bool v) => _useApi = v;

  // Hardcoded demo account
  static const demoEmail = 'test@local';
  static const demoPassword = '1234';

  /// Returns Either<Failure, Map> where the Map may contain 'token' and 'user'
  Future<Either<Failure, Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    if (!_useApi) {
      if (email == demoEmail && password == demoPassword) {
        return Right({
          'token': 'demo-token',
          'user': {'email': email},
        });
      }
      return Left(ServerFailure('Invalid credentials'));
    }

    try {
      // Usamos /api/auth/login para seguir la convención de la especificación
      // Si tu servidor expone la ruta en la raíz como /auth/login, cambia aquí
      // a '/auth/login' o descomenta la alternativa abajo.
      // Ejemplo alternativo si tu backend aún expone /auth/login:
      // final res = await ApiClient.instance.post('/auth/login', {
      final res = await ApiClient.instance.post('/api/auth/login', {
        'email': email,
        'password': password,
      }, (d) => d as Map<String, dynamic>);
      if (res['token'] != null) {
        return Right(res);
      }
      return Left(ServerFailure('Invalid response from server'));
    } catch (e) {
      if (e is ServerException) return Left(ServerFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }
}
