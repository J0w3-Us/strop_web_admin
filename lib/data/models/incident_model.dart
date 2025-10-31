import 'package:strop_admin_panel/domain/incidents/entities/incident_entity.dart';

class IncidentModel extends IncidentEntity {
  IncidentModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    required super.isCritical,
    required super.photoUrls,
    required super.createdBy,
    required super.createdAt,
    required super.timeline,
    super.assignedTo,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    final photoUrls =
        (json['photoUrls'] as List?)?.cast<String>() ?? <String>[];
    final timelineList =
        (json['timeline'] as List?)?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];

    return IncidentModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'safety',
      status: json['status']?.toString() ?? 'pending',
      isCritical: json['isCritical'] as bool? ?? false,
      photoUrls: photoUrls,
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      timeline: timelineList,
      assignedTo: json['assignedTo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'title': title,
    'description': description,
    'type': type,
    'status': status,
    'isCritical': isCritical,
    'photoUrls': photoUrls,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'timeline': timeline,
    'assignedTo': assignedTo,
  };

  IncidentEntity toEntity() => IncidentEntity(
    id: id,
    projectId: projectId,
    title: title,
    description: description,
    type: type,
    status: status,
    isCritical: isCritical,
    photoUrls: photoUrls,
    createdBy: createdBy,
    createdAt: createdAt,
    timeline: timeline,
    assignedTo: assignedTo,
  );
}
