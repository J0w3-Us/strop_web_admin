import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/domain/team/user.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProjectStatus _status = ProjectStatus.planned;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedMembers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final project = Project(
        id: ProjectRepository.instance.newId(),
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        members: _selectedMembers,
        documents: [],
      );

      await ProjectRepository.instance.upsert(project);

      // Sincronizar con el dashboard provider
      final projects = await ProjectRepository.instance.getAll();
      if (!mounted) return;
      context.read<DashboardProvider>().syncProjects(projects);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyecto creado exitosamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear proyecto: $e'),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nuevo Proyecto',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2C52),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: 'Código del proyecto *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El código es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Status and Dates
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ProjectStatus>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                              items: ProjectStatus.values
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        _getStatusDisplayName(status),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _status = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(isStart: true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de inicio',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _startDate == null
                                      ? 'Seleccionar fecha'
                                      : _formatDate(_startDate!),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(isStart: false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de fin (estimada)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _endDate == null
                                      ? 'Seleccionar fecha'
                                      : _formatDate(_endDate!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Team Selection
                      const Text(
                        'Equipo del Proyecto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<TeamProvider>(
                        builder: (context, teamProvider, _) {
                          final users = teamProvider.users;

                          if (users.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'No hay usuarios disponibles en el equipo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selectedMembers.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _selectedMembers.map((memberId) {
                                      final user = users.firstWhere(
                                        (u) => u.id == memberId,
                                        orElse: () => User(
                                          id: memberId,
                                          name: memberId,
                                          email: '',
                                          role: '',
                                        ),
                                      );
                                      return Chip(
                                        label: Text(user.name),
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedMembers.remove(memberId);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    hintText: 'Seleccionar miembro del equipo',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  value: null,
                                  items: users
                                      .where(
                                        (user) =>
                                            !_selectedMembers.contains(user.id),
                                      )
                                      .map(
                                        (user) => DropdownMenuItem(
                                          value: user.id,
                                          child: Text(
                                            '${user.name} (${user.role ?? 'Sin rol'})',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (userId) {
                                    if (userId != null) {
                                      setState(() {
                                        _selectedMembers.add(userId);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2C52),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Crear Proyecto'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDisplayName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return 'Planeado';
      case ProjectStatus.inProgress:
        return 'En Progreso';
      case ProjectStatus.onHold:
        return 'En Espera';
      case ProjectStatus.completed:
        return 'Completado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
