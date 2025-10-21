enum ProjectStatus { planned, inProgress, completed, onHold }

class Project {
  Project({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.status = ProjectStatus.planned,
    this.startDate,
    this.endDate,
    this.members = const [],
    this.documents = const [],
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> members; // ids of users for now
  final List<String> documents; // file names/urls stubs

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'status': status.name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'members': members,
      'documents': documents,
    };
  }

  static Project fromMap(Map map) {
    String statusStr = (map['status'] ?? 'planned').toString();
    final status = ProjectStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ProjectStatus.planned,
    );
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final members = (map['members'] as List?)?.cast<String>() ?? <String>[];
    final documents = (map['documents'] as List?)?.cast<String>() ?? <String>[];
    return Project(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      status: status,
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      members: members,
      documents: documents,
    );
  }
}
