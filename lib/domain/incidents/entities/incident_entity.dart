class IncidentEntity {
  IncidentEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.isCritical,
    required this.photoUrls,
    required this.createdBy,
    required this.createdAt,
    required this.timeline,
    this.assignedTo,
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final String type; // "progressReport", "problem", etc.
  final String status; // "open", "assigned", "closed"
  final bool isCritical;
  final List<String> photoUrls;
  final String createdBy; // ID de usuario
  final String? assignedTo; // ID de usuario, opcional
  final String createdAt; // String en formato ISO 8601
  final List<Map<String, dynamic>> timeline; // Lista de objetos con historial
}
