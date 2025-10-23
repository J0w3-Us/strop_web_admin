import 'package:flutter/material.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';
import 'package:strop_admin_panel/domain/projects/project_repository.dart';

class ProjectDetailViewScreen extends StatefulWidget {
  const ProjectDetailViewScreen({super.key, required this.id});

  final String id;

  @override
  State<ProjectDetailViewScreen> createState() =>
      _ProjectDetailViewScreenState();
}

class _ProjectDetailViewScreenState extends State<ProjectDetailViewScreen> {
  late Future<Project?> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = ProjectRepository.instance.getById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<Project?>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('Proyecto no encontrado'));
          }

          final project = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2C52),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Detalles del Proyecto',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Main Content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Project Info and Tasks
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProjectInfoCard(project),
                          const SizedBox(height: 24),
                          _buildPendingTasksCard(),
                          const SizedBox(height: 24),
                          _buildIncidentsCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right Column - Progress
                    Expanded(flex: 1, child: _buildProgressCard(project)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectInfoCard(Project project) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General del Proyecto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2C52),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nombre del Proyecto',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cliente',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Inversiones Globales S.A.C.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de Inicio',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.startDate != null
                            ? _formatDate(project.startDate!)
                            : '01 de Enero, 2023',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de Fin (Estimada)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.endDate != null
                            ? _formatDate(project.endDate!)
                            : '31 de Diciembre, 2024',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasksCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tareas Pendientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2C52),
              ),
            ),
            const SizedBox(height: 20),

            _buildTaskItem(
              'Aprobación de planos eléctricos',
              'Asignado a: Juan Pérez',
              Colors.orange,
              'Pendiente',
            ),
            const SizedBox(height: 16),
            _buildTaskItem(
              'Compra de acero estructural',
              'Asignado a: María López',
              Colors.red,
              'Urgente',
            ),
            const SizedBox(height: 16),
            _buildTaskItem(
              'Revisión de cimientos',
              'Asignado a: Carlos Sanchez',
              Colors.green,
              'A tiempo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String assignee,
    Color statusColor,
    String status,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                assignee,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Incidencias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2C52),
              ),
            ),
            const SizedBox(height: 20),

            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Reportado por',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Fecha',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Estado',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildIncidentRow(
              'Falla en bomba de agua',
              'Pedro Gómez',
              '15/06/2024',
              Colors.red,
              'Abierta',
            ),
            _buildIncidentRow(
              'Retraso en entrega de material',
              'Ana Torres',
              '12/06/2024',
              Colors.orange,
              'Pendiente',
            ),
            _buildIncidentRow(
              'Andamio dañado',
              'Luis Castillo',
              '10/06/2024',
              Colors.green,
              'Resuelta',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentRow(
    String description,
    String reporter,
    String date,
    Color statusColor,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(description, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(child: Text(reporter, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(date, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Project project) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avance y Hitos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2C52),
              ),
            ),
            const SizedBox(height: 24),

            // Circular progress
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 0.62,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '62%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2C52),
                            ),
                          ),
                          Text(
                            'Completado',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Milestones
            _buildMilestone('Inicio de cimentación', true),
            const SizedBox(height: 12),
            _buildMilestone('Estructura principal', true),
            const SizedBox(height: 12),
            _buildMilestone(
              'Instalaciones eléctricas y sanitarias',
              false,
              isNext: true,
            ),
            const SizedBox(height: 12),
            _buildMilestone('Acabados interiores', false),
            const SizedBox(height: 12),
            _buildMilestone('Entrega final', false),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(
    String title,
    bool isCompleted, {
    bool isNext = false,
  }) {
    Color color = isCompleted
        ? Colors.green
        : (isNext ? Colors.orange : Colors.grey);
    IconData icon = isCompleted
        ? Icons.check_circle
        : (isNext
              ? Icons.radio_button_unchecked
              : Icons.radio_button_unchecked);

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
              color: isCompleted
                  ? Colors.black
                  : (isNext ? Color(0xFF0A2C52) : Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day.toString().padLeft(2, '0')} de ${months[date.month - 1]}, ${date.year}';
  }
}
