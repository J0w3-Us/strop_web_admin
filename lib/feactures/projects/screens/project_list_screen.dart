import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';
import 'package:strop_admin_panel/feactures/projects/widgets/project_row.dart';
import 'package:strop_admin_panel/feactures/projects/widgets/create_project_dialog.dart';

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

  void _loadProjects() {
    setState(() {
      _projectsFuture = ProjectRepository.instance.search(_query);
    });
  }

  Future<void> _deleteProject(String id) async {
    await ProjectRepository.instance.delete(id);
    _loadProjects();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proyecto eliminado')));
    }
  }

  Future<void> _showCreateProjectDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateProjectDialog(),
    );

    if (result == true) {
      _loadProjects(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: FilledButton.icon(
              onPressed: _showCreateProjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('Crear'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8800),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<List<Project>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final projects = snapshot.data ?? [];

                    if (projects.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sin proyectos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _showCreateProjectDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Crear primer proyecto'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8800),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: const [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Nombre del Proyecto',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Cliente',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Estado',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Avance %',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                // Rows
                                ...projects.map(
                                  (p) => ProjectRow(
                                    project: p,
                                    onDelete: (id) => _deleteProject(id),
                                    onTap: (id) =>
                                        context.go('/app/projects/$id'),
                                  ),
                                ),
                                // Pagination (visual only)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: () {},
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A2C52),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text(
                                          '1',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('2'),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('3'),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('...'),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('10'),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
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
