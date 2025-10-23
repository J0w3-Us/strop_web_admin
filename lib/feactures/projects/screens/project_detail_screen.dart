import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/domain/team/user.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, this.id});

  final String? id; // null => creating

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  String _code = '';
  String _name = '';
  String? _description;
  ProjectStatus _status = ProjectStatus.planned;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _members = [];
  final List<String> _documents = [];
  bool _isLoading = false;
  late Future<Project?> _projectFuture;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _projectFuture = ProjectRepository.instance.getById(widget.id!);
    } else {
      _id = ProjectRepository.instance.newId();
      _projectFuture = Future.value(null);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final project = Project(
        id: _id,
        code: _code,
        name: _name,
        description: _description,
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        members: _members,
        documents: _documents,
      );
      await ProjectRepository.instance.upsert(project);

      // Sincronizar con el dashboard provider
      final projects = await ProjectRepository.instance.getAll();
      if (!mounted) return;
      context.read<DashboardProvider>().syncProjects(projects);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Proyecto guardado'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Project?>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final project = snapshot.data;
            if (project != null) {
              _id = project.id;
              _code = project.code;
              _name = project.name;
              _description = project.description;
              _status = project.status;
              _startDate = project.startDate;
              _endDate = project.endDate;
              // avoid adding duplicates when the FutureBuilder rebuilds
              if (_members.isEmpty) _members.addAll(project.members);
              if (_documents.isEmpty) _documents.addAll(project.documents);
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.id == null ? 'Nuevo Proyecto' : 'Editar Proyecto',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _save,
                          icon: _isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save_outlined),
                          label: const Text('Guardar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _code,
                                    decoration: const InputDecoration(labelText: 'Código del proyecto'),
                                    onSaved: (v) => _code = v!.trim(),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _name,
                                    decoration: const InputDecoration(labelText: 'Nombre'),
                                    onSaved: (v) => _name = v!.trim(),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _description,
                              decoration: const InputDecoration(labelText: 'Descripción'),
                              maxLines: 2,
                              onSaved: (v) => _description = v?.trim(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<ProjectStatus>(
                                    initialValue: _status,
                                    items: ProjectStatus.values
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                                        .toList(),
                                    onChanged: (v) => setState(() => _status = v!),
                                    decoration: const InputDecoration(labelText: 'Estado'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text: _startDate == null
                                                ? ''
                                                : _startDate!.toIso8601String().split('T').first,
                                          ),
                                          decoration: const InputDecoration(labelText: 'Inicio'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => _pickDate(isStart: true),
                                        icon: const Icon(Icons.event_outlined),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text: _endDate == null ? '' : _endDate!.toIso8601String().split('T').first,
                                          ),
                                          decoration: const InputDecoration(labelText: 'Fin (estimado)'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => _pickDate(isStart: false),
                                        icon: const Icon(Icons.event_outlined),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Team section: uses TeamProvider to pick members (multi-select)
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Equipo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 8),
                            Consumer<TeamProvider>(
                              builder: (context, team, _) {
                                final users = team.users;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (users.isEmpty)
                                      Row(
                                        children: [
                                          const Text('No hay usuarios. '),
                                          TextButton(
                                            onPressed: () => Navigator.pushNamed(context, '/app/team'),
                                            child: const Text('Crear equipo'),
                                          ),
                                        ],
                                      )
                                    else
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          for (final id in _members)
                                            Chip(
                                              label: Text(
                                                users
                                                    .firstWhere(
                                                      (u) => u.id == id,
                                                      orElse: () => User(id: id, name: id, email: '', role: ''),
                                                    )
                                                    .name,
                                              ),
                                            ),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final selected = await showDialog<List<String>>(
                                          context: context,
                                          builder: (_) => _SelectMembersDialog(
                                            available: users,
                                            selectedIds: List<String>.from(_members),
                                          ),
                                        );
                                        if (selected != null) {
                                          setState(
                                            () => _members
                                              ..clear()
                                              ..addAll(selected),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.person_add_alt_1_outlined),
                                      label: const Text('Seleccionar miembros'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Documentos (placeholder)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final d in _documents) Chip(label: Text(d)),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() => _documents.add('doc_${_documents.length + 1}.pdf'));
                                  },
                                  icon: const Icon(Icons.upload_file_outlined),
                                  label: const Text('Subir documento'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _SelectMembersDialog extends StatefulWidget {
  const _SelectMembersDialog({Key? key, required this.available, required this.selectedIds}) : super(key: key);

  final List<User> available;
  final List<String> selectedIds;

  @override
  State<_SelectMembersDialog> createState() => _SelectMembersDialogState();
}

class _SelectMembersDialogState extends State<_SelectMembersDialog> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar miembros'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final u in widget.available)
                CheckboxListTile(
                  value: _selected.contains(u.id),
                  title: Text(u.name),
                  subtitle: Text(u.role ?? ''),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        if (!_selected.contains(u.id)) _selected.add(u.id);
                      } else {
                        _selected.remove(u.id);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(_selected), child: const Text('Seleccionar')),
      ],
    );
  }
}
