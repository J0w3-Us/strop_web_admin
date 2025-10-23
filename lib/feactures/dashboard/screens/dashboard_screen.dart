import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/cost_control_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/small_metric_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/project_progress_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/inbox_actions_table.dart';
// schedule and monthly progress widgets are not used in the redesigned layout
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';

/// Pantalla principal del Dashboard - Conectado con estado dinámico
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0A2C52),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8800), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar(context, 'Acción ejecutada ✓');
            },
            child: const Text('Ver Detalles'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + selector de proyecto en la esquina superior derecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Centro de Mando',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
                ),
                // Selector dinámico de proyecto usando DashboardProvider
                Consumer<DashboardProvider>(
                  builder: (context, dashboardProvider, _) {
                    final projects = dashboardProvider.projects;
                    final selectedId = dashboardProvider.selectedProjectId;
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 300,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedId,
                            hint: const Text('Vista Global (Todos los Proyectos)', overflow: TextOverflow.ellipsis),
                            isExpanded: true,
                            icon: const Icon(Icons.expand_more, color: Color(0xFF0A2C52)),
                            selectedItemBuilder: (ctx) {
                              // Selected display: null (global) + project names
                              return [
                                const Text(
                                  'Vista Global (Todos los Proyectos)',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Color(0xFF0A2C52)),
                                ),
                                ...projects.map(
                                  (p) => Text(
                                    p.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF0A2C52)),
                                  ),
                                ),
                              ];
                            },
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Vista Global (Todos los Proyectos)'),
                              ),
                              ...projects.map((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.name))),
                            ],
                            onChanged: (v) => dashboardProvider.setSelectedProject(v),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Top small metrics row
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SmallMetricCard(
                        value: dashboardProvider.criticalIncidentsCount,
                        label: 'Críticas',
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SmallMetricCard(
                        value: dashboardProvider.highIncidentsCount,
                        label: 'Medias/Altas',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SmallMetricCard(
                        value: dashboardProvider.lowIncidentsCount,
                        label: 'Bajas',
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Segunda fila: Progreso y Control de Gastos
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, _) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ProjectProgressCard(
                          progress: dashboardProvider.generalProgress,
                          phase: 'Estructura',
                          eta: '15/12/2024',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: CostControlCard(
                          title: 'Control de Gastos',
                          amount: '\$${dashboardProvider.totalExpenses.toStringAsFixed(0)}',
                          subtitle: 'Presupuesto Ejecutado',
                          currentValue: dashboardProvider.totalExpenses,
                          maxValue: dashboardProvider.totalBudget == 0 ? 1 : dashboardProvider.totalBudget,
                          onTap: () => _showDetailDialog(
                            context,
                            'Control de Gastos',
                            'Presupuesto Total: \$${dashboardProvider.totalBudget.toStringAsFixed(0)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Bandeja de Entrada (tabla)
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, _) {
                final items = [
                  InboxItem(
                    priority: 'Crítica',
                    task: 'Falta de material de seguridad en Área 5',
                    project: 'Torre Residencial Centinela',
                    priorityColor: Colors.redAccent,
                  ),
                  InboxItem(
                    priority: 'Crítica',
                    task: 'Aprobación de presupuesto para cimientos',
                    project: 'Complejo de Oficinas Nova',
                    priorityColor: Colors.redAccent,
                  ),
                  InboxItem(
                    priority: 'Media/Alta',
                    task: 'Revisar plano estructural modificado',
                    project: 'Centro Comercial El Mirador',
                    priorityColor: Colors.orange,
                  ),
                ];

                return InboxActionsTable(items: items);
              },
            ),
            const SizedBox(height: 16),

            // (Se eliminó la tarjeta de 'Acciones Pendientes' — queda solo la Bandeja de Entrada arriba)
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // helper removed: monthly/schedule widgets are no longer used in redesigned layout
}
