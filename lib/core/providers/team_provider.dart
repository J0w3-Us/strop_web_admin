import 'package:flutter/foundation.dart';
import 'package:strop_admin_panel/domain/team/user.dart';
import 'package:strop_admin_panel/domain/team/user_repository.dart';

class TeamProvider extends ChangeNotifier {
  List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  Future<void> load() async {
    final items = await UserRepository.instance.getAll();
    _users = items;
    notifyListeners();
  }

  Future<User> create(String name, {String? email, String? role}) async {
    final user = User(id: UserRepository.instance.newId(), name: name, email: email, role: role);
    final created = await UserRepository.instance.create(user);
    _users.add(created);
    notifyListeners();
    return created;
  }

  Future<void> delete(String id) async {
    await UserRepository.instance.delete(id);
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
