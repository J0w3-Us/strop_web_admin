import 'dart:math';

import 'package:strop_admin_panel/domain/projects/project.dart';

/// Simulated API Project Repository
class ProjectRepository {
  ProjectRepository._() {
    _initializeSampleData();
  }
  static final ProjectRepository instance = ProjectRepository._();

  final List<Project> _projects = [];

  void _initializeSampleData() {
    _projects.addAll([
      Project(
        id: '1',
        code: 'ECC001',
        name: 'Edificio Corporativo Central',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 40)),
        status: ProjectStatus.inProgress,
      ),
      Project(
        id: '2',
        code: 'RLV002',
        name: 'Residencial Las Vistas Fase II',
        startDate: DateTime.now().subtract(const Duration(days: 120)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        status: ProjectStatus.completed,
      ),
      Project(
        id: '3',
        code: 'PIN003',
        name: 'Parque Industrial del Norte',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        status: ProjectStatus.planned,
      ),
      Project(
        id: '4',
        code: 'CCM004',
        name: 'Centro Comercial Metrópolis',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        status: ProjectStatus.onHold,
      ),
    ]);
  }

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
