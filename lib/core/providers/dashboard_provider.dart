import 'package:flutter/foundation.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/incidents/incident.dart';

/// Gestor de estado central de la aplicación
/// Actúa como backend temporal mientras se integra la API real
class DashboardProvider extends ChangeNotifier {
  // Estado de la aplicación
  List<Project> _projects = [];
  final List<Incident> _incidents = [];
  double _totalBudget = 0.0;
  double _totalExpenses = 0.0;
  final Map<String, double> _monthlyProgress = {};

  // Getters para acceso de solo lectura
  List<Project> get projects => List.unmodifiable(_projects);
  // Currently selected project id for UI filters. null means 'Vista Global'.
  String? _selectedProjectId;
  String? get selectedProjectId => _selectedProjectId;
  Project? get selectedProject {
    if (_selectedProjectId == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == _selectedProjectId);
    } catch (_) {
      return null;
    }
  }

  List<Incident> get incidents => List.unmodifiable(_incidents);
  double get totalBudget => _totalBudget;
  double get totalExpenses => _totalExpenses;
  Map<String, double> get monthlyProgress => Map.unmodifiable(_monthlyProgress);

  // Estadísticas calculadas
  int get activeProjectsCount =>
      _projects.where((p) => p.status == ProjectStatus.inProgress).length;

  int get totalProjectsCount => _projects.length;

  int get openIncidentsCount =>
      _incidents.where((i) => i.status == IncidentStatus.open).length;

  // Breakdown by severity
  int get criticalIncidentsCount => _incidents
      .where((i) => i.priority == IncidentPriority.critical)
      .where(
        (i) =>
            i.status == IncidentStatus.open ||
            i.status == IncidentStatus.inProgress,
      )
      .length;

  int get highIncidentsCount => _incidents
      .where((i) => i.priority == IncidentPriority.high)
      .where(
        (i) =>
            i.status == IncidentStatus.open ||
            i.status == IncidentStatus.inProgress,
      )
      .length;

  int get mediumIncidentsCount => _incidents
      .where((i) => i.priority == IncidentPriority.medium)
      .where(
        (i) =>
            i.status == IncidentStatus.open ||
            i.status == IncidentStatus.inProgress,
      )
      .length;

  int get lowIncidentsCount => _incidents
      .where((i) => i.priority == IncidentPriority.low)
      .where(
        (i) =>
            i.status == IncidentStatus.open ||
            i.status == IncidentStatus.inProgress,
      )
      .length;

  int get pendingActionsCount {
    // Ejemplo: contar proyectos pendientes de aprobación o incidentes críticos
    return _projects.where((p) => p.status == ProjectStatus.planned).length +
        _incidents
            .where(
              (i) =>
                  i.priority == IncidentPriority.critical &&
                  i.status != IncidentStatus.resolved,
            )
            .length;
  }

  double get generalProgress {
    if (_projects.isEmpty) return 0.0;
    // Calcular progreso promedio de proyectos activos
    final activeProjects = _projects
        .where((p) => p.status == ProjectStatus.inProgress)
        .toList();
    if (activeProjects.isEmpty) return 0.0;
    // Por ahora retornamos un valor fijo, se puede mejorar con progreso real por proyecto
    return 0.75;
  }

  double get budgetUsagePercentage {
    if (_totalBudget == 0) return 0.0;
    return (_totalExpenses / _totalBudget).clamp(0.0, 1.0);
  }

  // ==================== Métodos para modificar datos ====================

  /// Añadir un proyecto
  void addProject(Project project) {
    _projects.add(project);
    // Actualizar presupuesto si el proyecto tiene un monto inicial (simulado)
    // En una app real, esto vendría del modelo Project
    _totalBudget += 100000; // valor simulado por proyecto
    notifyListeners();
  }

  /// Actualizar un proyecto existente
  void updateProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
    }
  }

  /// Eliminar un proyecto
  void deleteProject(String projectId) {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex != -1) {
      _projects.removeAt(projectIndex);
      // Ajustar presupuesto
      _totalBudget -= 100000; // valor simulado
      notifyListeners();
    }
  }

  /// Añadir una incidencia
  void addIncident(Incident incident) {
    _incidents.add(incident);
    notifyListeners();
  }

  /// Actualizar una incidencia
  void updateIncident(Incident updatedIncident) {
    final index = _incidents.indexWhere((i) => i.id == updatedIncident.id);
    if (index != -1) {
      _incidents[index] = updatedIncident;
      notifyListeners();
    }
  }

  /// Eliminar una incidencia
  void deleteIncident(String incidentId) {
    _incidents.removeWhere((i) => i.id == incidentId);
    notifyListeners();
  }

  /// Registrar un gasto
  void addExpense(double amount) {
    _totalExpenses += amount;
    notifyListeners();
  }

  /// Actualizar progreso mensual
  void updateMonthlyProgress(String month, double progress) {
    _monthlyProgress[month] = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Cargar datos iniciales (simulados o desde API)
  Future<void> loadInitialData() async {
    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 300));

    // Datos de ejemplo - en producción vendrían de la API
    // Por ahora, dejamos las listas vacías para que el dashboard muestre ceros
    // y el usuario vaya llenando datos

    notifyListeners();
  }

  /// Sincronizar con ProjectRepository existente
  void syncProjects(List<Project> projectsList) {
    _projects = List.from(projectsList);
    _totalBudget = projectsList.length * 100000.0; // simulado
    // If the previously selected project id no longer exists, reset selection
    if (_selectedProjectId != null &&
        !_projects.any((p) => p.id == _selectedProjectId)) {
      _selectedProjectId = null;
    }
    notifyListeners();
  }

  /// Seleccionar proyecto para filtrar vistas del dashboard (null = vista global)
  void setSelectedProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  /// Limpiar todos los datos (útil para testing o reset)
  void clearAll() {
    _projects.clear();
    _incidents.clear();
    _totalBudget = 0.0;
    _totalExpenses = 0.0;
    _monthlyProgress.clear();
    notifyListeners();
  }
}
