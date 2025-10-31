import 'package:flutter_test/flutter_test.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';
// Tests now use repository Either-returning methods directly

void main() {
  group('ProjectRepository', () {
    test('can upsert and read project', () async {
      final repo = ProjectRepository.instance;
      final id = repo.newId();
      final project = Project(id: id, code: 'T-1', name: 'Test Project');

      await repo.upsert(project);

      final either = await repo.getByIdEither(id);
      either.match(
        (failure) =>
            fail('Expected project but got failure: ${failure.message}'),
        (proj) {
          expect(proj, isNotNull);
          expect(proj!.name, 'Test Project');
        },
      );
    });

    test('can search projects', () async {
      final repo = ProjectRepository.instance;
      final id1 = repo.newId();
      final id2 = repo.newId();
      await repo.upsert(
        Project(id: id1, code: 'T-1', name: 'Unique Test Project'),
      );
      await repo.upsert(Project(id: id2, code: 'T-2', name: 'Another Project'));

      final results = await repo.search('Unique');
      expect(results.length, 1);
      expect(results.first.name, 'Unique Test Project');
    });

    test('can delete project', () async {
      final repo = ProjectRepository.instance;
      final id = repo.newId();
      final project = Project(id: id, code: 'T-1', name: 'Test Project');
      await repo.upsert(project);

      await repo.delete(id);

      final either = await repo.getByIdEither(id);
      either.match(
        (failure) =>
            fail('Expected null project but got failure: ${failure.message}'),
        (proj) => expect(proj, isNull),
      );
    });
  });
}
