/// Excepciones que ocurren en la capa de datos
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);

  @override
  String toString() => 'NetworkException: $message';
}
