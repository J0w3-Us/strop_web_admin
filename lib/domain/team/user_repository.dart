import 'dart:math';
import 'package:strop_admin_panel/domain/team/user.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final List<User> _users = [];
  static const Duration _apiDelay = Duration(milliseconds: 300);

  Future<List<User>> getAll() async {
    await Future.delayed(_apiDelay);
    return List.unmodifiable(_users);
  }

  Future<User?> getById(String id) async {
    await Future.delayed(_apiDelay);
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<User> create(User user) async {
    await Future.delayed(_apiDelay);
    _users.add(user);
    return user;
  }

  Future<User> update(User user) async {
    await Future.delayed(_apiDelay);
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
    return user;
  }

  Future<void> delete(String id) async {
    await Future.delayed(_apiDelay);
    _users.removeWhere((u) => u.id == id);
  }

  String newId() => Random().nextInt(1 << 31).toString();
}
