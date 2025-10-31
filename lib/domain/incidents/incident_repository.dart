import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:strop_admin_panel/core/services/api_client.dart';
import 'package:strop_admin_panel/domain/exceptions.dart';
import 'package:strop_admin_panel/domain/failures.dart';
import 'package:strop_admin_panel/domain/incidents/incident.dart';
import 'package:strop_admin_panel/data/models/incident_model.dart';

class IncidentRepository {
  IncidentRepository._();
  static final IncidentRepository instance = IncidentRepository._();

  Future<List<Incident>> getAll() async {
    try {
      final response = await ApiClient.instance.get('/incidents', (json) {
        return (json as List)
            .map((item) => IncidentModel.fromJson(item))
            .toList();
      });
      return response.cast<Incident>();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load incidents: $e');
    }
  }

  Future<Either<Failure, List<Incident>>> getAllEither() async {
    try {
      final incidents = await getAll();
      return Right(incidents);
    } catch (e) {
      if (e is ServerException) return Left(ServerFailure(e.message));
      if (e is NetworkException) return Left(NetworkFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<Incident>> getByProject(String projectId) async {
    try {
      final response = await ApiClient.instance.get(
        '/incidents?projectId=$projectId',
        (json) {
          return (json as List)
              .map((item) => IncidentModel.fromJson(item))
              .toList();
        },
      );
      return response.cast<Incident>();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load incidents for project: $e');
    }
  }

  Future<Incident?> getById(String id) async {
    try {
      final response = await ApiClient.instance.get('/incidents/$id', (json) {
        return IncidentModel.fromJson(json);
      });
      return response as Incident;
    } catch (e) {
      if (e is ServerException && e.message.contains('404')) return null;
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load incident: $e');
    }
  }

  Future<Either<Failure, Incident?>> getByIdEither(String id) async {
    try {
      final incident = await getById(id);
      return Right(incident);
    } catch (e) {
      if (e is ServerException) return Left(ServerFailure(e.message));
      if (e is NetworkException) return Left(NetworkFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Incident> create(Incident incident) async {
    try {
      final incidentModel = IncidentModel(
        id: incident.id,
        projectId: incident.projectId ?? '',
        title: incident.title,
        description: incident.description,
        type: 'safety', // Default type
        status: 'open', // Default status
        isCritical: incident.priority == IncidentPriority.critical,
        photoUrls: <String>[], // Empty photo URLs
        createdBy: incident.reportedBy ?? '',
        createdAt: DateTime.now().toIso8601String(),
        timeline: <Map<String, dynamic>>[], // Empty timeline
        assignedTo: incident.assignedTo,
      );

      final response = await ApiClient.instance.post(
        '/incidents',
        incidentModel.toJson(),
        (json) {
          return IncidentModel.fromJson(json);
        },
      );
      return response as Incident;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create incident: $e');
    }
  }

  Future<Incident> update(Incident incident) async {
    try {
      final incidentModel = IncidentModel(
        id: incident.id,
        projectId: incident.projectId ?? '',
        title: incident.title,
        description: incident.description,
        type: 'safety', // Default type
        status: incident.status.name,
        isCritical: incident.priority == IncidentPriority.critical,
        photoUrls: <String>[], // Empty photo URLs
        createdBy: incident.reportedBy ?? '',
        createdAt:
            incident.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        timeline: <Map<String, dynamic>>[], // Empty timeline
        assignedTo: incident.assignedTo,
      );

      final response = await ApiClient.instance.put(
        '/incidents/${incident.id}',
        incidentModel.toJson(),
        (json) {
          return IncidentModel.fromJson(json);
        },
      );
      return response as Incident;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update incident: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await ApiClient.instance.delete('/incidents/$id', (json) => json);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete incident: $e');
    }
  }

  String newId() => Random().nextInt(1 << 31).toString();
}
