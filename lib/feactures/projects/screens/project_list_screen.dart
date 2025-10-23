import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  String _query = '';
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle external query param
    final state = GoRouterState.of(context);
    final qp = state.uri.queryParameters['q'];
    if (qp != null && qp != _query) {
      _query = qp;
      _loadProjects();
    }
  }

  void _loadProjects() {
    setState(() {
      _projectsFuture = ProjectRepository.instance.search(_query);
    });
    // Sincronizar con el provider
    _syncWithProvider();
  }

  Future<void> _syncWithProvider() async {
    final projects = await ProjectRepository.instance.getAll();
    if (mounted) {
      context.read<DashboardProvider>().syncProjects(projects);
    }
  }

  Future<void> _deleteProject(String id) async {
    try {
      await ProjectRepository.instance.delete(id);
      _loadProjects(); // Refresh list and sync provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proyecto eliminado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Proyectos',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.go('/app/projects/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Proyecto'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o código...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                _query = v;
                _loadProjects();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: FutureBuilder<List<Project>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final projects = snapshot.data ?? [];
                      if (projects.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sin proyectos', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () => context.go('/app/projects/new'),
                                icon: const Icon(Icons.add),
                                label: const Text('Crear primer proyecto'),
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8800)),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Inicio')),
                            DataColumn(label: Text('Fin')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: projects
                              .map(
                                (p) => DataRow(
                                  cells: [
                                    DataCell(Text(p.code)),
                                    DataCell(Text(p.name)),
                                    DataCell(Text(p.status.name)),
                                    DataCell(Text(p.startDate?.toIso8601String().split('T').first ?? '-')),
                                    DataCell(Text(p.endDate?.toIso8601String().split('T').first ?? '-')),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility_outlined),
                                            onPressed: () => context.go('/app/projects/${p.id}'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => _deleteProject(p.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
