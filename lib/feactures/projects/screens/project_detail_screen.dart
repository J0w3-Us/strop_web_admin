import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';

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
      if (mounted) {
        final projects = await ProjectRepository.instance.getAll();
        context.read<DashboardProvider>().syncProjects(projects);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyecto guardado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
              _members.addAll(project.members);
              _documents.addAll(project.documents);
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
                            widget.id == null
                                ? 'Nuevo Proyecto'
                                : 'Editar Proyecto',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2C52),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _save,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: const Text('Guardar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _code,
                                    decoration: const InputDecoration(
                                      labelText: 'Código del proyecto',
                                    ),
                                    onSaved: (v) => _code = v!.trim(),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Requerido'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _name,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre',
                                    ),
                                    onSaved: (v) => _name = v!.trim(),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Requerido'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _description,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                              ),
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
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _status = v!),
                                    decoration: const InputDecoration(
                                      labelText: 'Estado',
                                    ),
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
                                                : _startDate!
                                                      .toIso8601String()
                                                      .split('T')
                                                      .first,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Inicio',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            _pickDate(isStart: true),
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
                                            text: _endDate == null
                                                ? ''
                                                : _endDate!
                                                      .toIso8601String()
                                                      .split('T')
                                                      .first,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Fin (estimado)',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            _pickDate(isStart: false),
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
                    // Secciones placeholder para TeamScreen y Documentos
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Equipo (placeholder)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final m in _members) Chip(label: Text(m)),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(
                                      () => _members.add(
                                        'user${_members.length + 1}',
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.person_add_alt_1_outlined,
                                  ),
                                  label: const Text('Agregar miembro'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Documentos (placeholder)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final d in _documents)
                                  Chip(label: Text(d)),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(
                                      () => _documents.add(
                                        'doc_${_documents.length + 1}.pdf',
                                      ),
                                    );
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
