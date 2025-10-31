import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:strop_admin_panel/core/services/api_client.dart';
import 'package:strop_admin_panel/domain/exceptions.dart';
import 'package:strop_admin_panel/domain/failures.dart';
import 'package:strop_admin_panel/domain/team/user.dart';
import 'package:strop_admin_panel/data/models/user_model.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  Future<List<User>> getAll() async {
    try {
      final response = await ApiClient.instance.get('/users', (json) {
        return (json as List).map((item) => UserModel.fromJson(item)).toList();
      });
      return response.cast<User>();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load users: $e');
    }
  }

  Future<Either<Failure, List<User>>> getAllEither() async {
    try {
      final users = await getAll();
      return Right(users);
    } catch (e) {
      if (e is ServerException) return Left(ServerFailure(e.message));
      if (e is NetworkException) return Left(NetworkFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<User?> getById(String id) async {
    try {
      final response = await ApiClient.instance.get('/users/$id', (json) {
        return UserModel.fromJson(json);
      });
      return response as User;
    } catch (e) {
      if (e is ServerException && e.message.contains('404')) return null;
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load user: $e');
    }
  }

  Future<User> create(User user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        name: user.name,
        email: user.email ?? '',
        role: user.role ?? '',
        phone: '', // Default empty phone
        isActive: true, // Default active
      );

      final response = await ApiClient.instance.post(
        '/users',
        userModel.toJson(),
        (json) {
          return UserModel.fromJson(json);
        },
      );
      return response as User;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create user: $e');
    }
  }

  Future<User> update(User user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        name: user.name,
        email: user.email ?? '',
        role: user.role ?? '',
        phone: '', // Default empty phone
        isActive: true, // Default active
      );

      final response = await ApiClient.instance.put(
        '/users/${user.id}',
        userModel.toJson(),
        (json) {
          return UserModel.fromJson(json);
        },
      );
      return response as User;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update user: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await ApiClient.instance.delete('/users/$id', (json) => json);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete user: $e');
    }
  }

  String newId() => Random().nextInt(1 << 31).toString();
}
