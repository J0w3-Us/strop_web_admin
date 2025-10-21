import 'dart:math';

import 'package:strop_admin_panel/domain/projects/project.dart';

/// Simulated API Project Repository
class ProjectRepository {
  ProjectRepository._();
  static final ProjectRepository instance = ProjectRepository._();

  final List<Project> _projects = [];

  // Simulate API delay
  static const Duration _apiDelay = Duration(milliseconds: 500);

  Future<List<Project>> getAll() async {
    await Future.delayed(_apiDelay);
    return List.unmodifiable(_projects);
  }

  Future<List<Project>> search(String query) async {
    await Future.delayed(_apiDelay);
    if (query.trim().isEmpty) return await getAll();
    final all = await getAll();
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.code.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<Project?> getById(String id) async {
    await Future.delayed(_apiDelay);
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Project project) async {
    await Future.delayed(_apiDelay);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      _projects.add(project);
    } else {
      _projects[index] = project;
    }
    // Simulate API success
  }

  Future<void> delete(String id) async {
    await Future.delayed(_apiDelay);
    _projects.removeWhere((p) => p.id == id);
    // Simulate API success
  }

  String newId() => Random().nextInt(1 << 31).toString();
}
