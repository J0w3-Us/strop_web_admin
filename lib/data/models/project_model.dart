import 'package:strop_admin_panel/domain/projects/entities/project_entity.dart';

/// ProjectModel añade serialización al ProjectEntity.
class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.id,
    required super.name,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.budget,
    required super.team,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final team = (json['team'] as List?)?.cast<String>() ?? <String>[];

    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      startDate:
          json['startDate']?.toString() ?? DateTime.now().toIso8601String(),
      endDate: json['endDate']?.toString() ?? DateTime.now().toIso8601String(),
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      team: team,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'team': team,
    };
  }

  /// Convierta a la entidad de dominio (ProjectEntity)
  ProjectEntity toEntity() => ProjectEntity(
    id: id,
    name: name,
    status: status,
    startDate: startDate,
    endDate: endDate,
    budget: budget,
    team: team,
  );
}
