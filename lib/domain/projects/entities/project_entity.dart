class ProjectEntity {
  ProjectEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.team,
  });

  final String id;
  final String name;
  final String status; // "active" o "archived"
  final String startDate; // String en formato ISO 8601
  final String endDate; // String en formato ISO 8601
  final double budget;
  final List<String> team; // Lista de IDs de usuario
}
