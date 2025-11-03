import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:strop_admin_panel/core/services/api_client.dart';
import 'package:strop_admin_panel/domain/exceptions.dart';
import 'package:strop_admin_panel/domain/failures.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/data/models/project_model.dart';

/// Real API Project Repository
class ProjectRepository {
  ProjectRepository._();
  static final ProjectRepository instance = ProjectRepository._();

  Future<List<Project>> getAll() async {
    try {
  final response = await ApiClient.instance.get('/api/projects', (json) {
        return (json as List)
            .map((item) => ProjectModel.fromJson(item))
            .toList();
      });
      return response.cast<Project>();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load projects: $e');
    }
  }

  /// Either-based API to return either a Failure or the projects list
  Future<Either<Failure, List<Project>>> getAllEither() async {
    try {
      final projects = await getAll();
      return Right(projects);
    } catch (e) {
      if (e is ServerException) return Left(ServerFailure(e.message));
      if (e is NetworkException) return Left(NetworkFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<Project>> search(String query) async {
    try {
      if (query.trim().isEmpty) return await getAll();

      final response = await ApiClient.instance.get(
        '/api/projects?search=${Uri.encodeComponent(query)}',
        (json) {
          return (json as List)
              .map((item) => ProjectModel.fromJson(item))
              .toList();
        },
      );
      return response.cast<Project>();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to search projects: $e');
    }
  }

  Future<Project?> getById(String id) async {
    try {
  final response = await ApiClient.instance.get('/api/projects/$id', (json) {
        return ProjectModel.fromJson(json);
      });
      return response as Project;
    } catch (e) {
      if (e is ServerException && e.message.contains('404')) return null;
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load project: $e');
    }
  }

  Future<Either<Failure, Project?>> getByIdEither(String id) async {
    try {
      final project = await getById(id);
      return Right(project);
    } catch (e) {
      if (e is ServerException) return Left(ServerFailure(e.message));
      if (e is NetworkException) return Left(NetworkFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> upsert(Project project) async {
    try {
      final projectModel = ProjectModel(
        id: project.id,
        name: project.name,
        status: project.status.name,
        startDate:
            project.startDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        endDate:
            project.endDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        budget: 0.0, // Default budget
        team: project.members,
      );

      if (project.id.isEmpty) {
        // Create new project
        await ApiClient.instance.post(
          '/api/projects',
          projectModel.toJson(),
          (json) => json,
        );
      } else {
        // Update existing project
        await ApiClient.instance.put(
          '/api/projects/${project.id}',
          projectModel.toJson(),
          (json) => json,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to save project: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
  await ApiClient.instance.delete('/api/projects/$id', (json) => json);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete project: $e');
    }
  }

  String newId() => Random().nextInt(1 << 31).toString();
}
