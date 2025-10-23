import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strop_admin_panel/feactures/projects/widgets/project_row.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';

void main() {
  testWidgets('ProjectRow renders name, client and progress', (tester) async {
    final project = Project(
      id: '1',
      name: 'Test Project',
      code: 'TP-1',
      status: ProjectStatus.inProgress,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectRow(project: project, onDelete: (_) {}, onTap: (_) {}),
        ),
      ),
    );

    expect(find.text('Test Project'), findsOneWidget);
    // client fallback is 'Empresa ABC'
    expect(find.text('Empresa ABC'), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
  });
}
