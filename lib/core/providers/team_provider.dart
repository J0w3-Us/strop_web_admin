import 'package:flutter/foundation.dart';
import 'package:strop_admin_panel/core/state/data_state.dart';
import 'package:strop_admin_panel/domain/team/user.dart';
import 'package:strop_admin_panel/domain/team/user_repository.dart';

class TeamProvider extends ChangeNotifier {
  List<User> _users = [];

  // Async state tracking
  DataState state = DataState.initial;
  String? errorMessage;

  List<User> get users => List.unmodifiable(_users);

  /// Backwards-compatible load() method
  Future<void> load() async => fetchTeamData();

  /// New async loader using DataState
  Future<void> fetchTeamData() async {
    state = DataState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await UserRepository.instance.getAllEither();
      result.fold(
        (failure) {
          errorMessage = failure.message;
          state = DataState.error;
        },
        (items) {
          _users = items;
          state = DataState.success;
        },
      );
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      state = DataState.error;
      notifyListeners();
    }
  }

  Future<User> create(String name, {String? email, String? role}) async {
    final user = User(
      id: UserRepository.instance.newId(),
      name: name,
      email: email,
      role: role,
    );
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
