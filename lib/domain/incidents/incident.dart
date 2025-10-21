enum IncidentStatus { open, inProgress, resolved, closed }

enum IncidentPriority { low, medium, high, critical }

class Incident {
  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.status = IncidentStatus.open,
    this.projectId,
    this.reportedBy,
    this.assignedTo,
    this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String title;
  final String description;
  final IncidentPriority priority;
  final IncidentStatus status;
  final String? projectId;
  final String? reportedBy;
  final String? assignedTo;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    IncidentPriority? priority,
    IncidentStatus? status,
    String? projectId,
    String? reportedBy,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      reportedBy: reportedBy ?? this.reportedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
