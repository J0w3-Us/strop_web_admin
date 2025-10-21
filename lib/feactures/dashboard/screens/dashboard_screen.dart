import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/metric_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/circular_progress_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/cost_control_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/incident_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/schedule_progress_card.dart';
import 'package:strop_admin_panel/feactures/dashboard/widgets/monthly_progress_card.dart';
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8800),
              foregroundColor: Colors.white,
            ),
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
            // Título
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2C52),
              ),
            ),
            const SizedBox(height: 32),

            // KPIs dinámicos - Conectados con DashboardProvider
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Proyectos Activos',
                        value: '${dashboardProvider.activeProjectsCount}',
                        onTap: () => context.go('/app/projects'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricCard(
                        title: 'Total de Proyectos',
                        value: '${dashboardProvider.totalProjectsCount}',
                        onTap: () => context.go('/app/projects'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Acciones Pendientes - Dinámico
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, _) {
                return MetricCard(
                  title: 'Acciones Pendientes',
                  value: '${dashboardProvider.pendingActionsCount}',
                  onTap: () => _showDetailDialog(
                    context,
                    'Acciones Pendientes',
                    dashboardProvider.pendingActionsCount == 0
                        ? 'No hay acciones pendientes en este momento.'
                        : 'Tienes ${dashboardProvider.pendingActionsCount} acciones que requieren tu atención.',
                  ),
                  actionButton: ElevatedButton(
                    onPressed: () => context.go('/app/authorizations'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8800),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Ver todas'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Primera fila: Avance General, Control de Costos, Incidencias
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                if (isWide) {
                  return Consumer<DashboardProvider>(
                    builder: (context, dashboardProvider, _) {
                      final progressPercentage =
                          dashboardProvider.generalProgress * 100;
                      final budgetUsedPercentage =
                          dashboardProvider.budgetUsagePercentage * 100;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CircularProgressCard(
                              title: 'Avance General de Obra',
                              percentage: progressPercentage,
                              subtitle: 'Completado',
                              onTap: () => _showDetailDialog(
                                context,
                                'Avance General de Obra',
                                'Progreso actual: ${progressPercentage.toStringAsFixed(0)}%\n\n'
                                    'Este valor se calcula automáticamente basado en el progreso de proyectos activos.',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CostControlCard(
                              title: 'Control de Costos',
                              amount:
                                  '\$${dashboardProvider.totalExpenses.toStringAsFixed(0)}',
                              subtitle: 'Gasto Real',
                              currentValue: dashboardProvider.totalExpenses,
                              maxValue: dashboardProvider.totalBudget == 0
                                  ? 1
                                  : dashboardProvider.totalBudget,
                              onTap: () => _showDetailDialog(
                                context,
                                'Control de Costos',
                                'Presupuesto Total: \$${dashboardProvider.totalBudget.toStringAsFixed(0)}\n'
                                    'Gasto Real: \$${dashboardProvider.totalExpenses.toStringAsFixed(0)}\n'
                                    'Disponible: \$${(dashboardProvider.totalBudget - dashboardProvider.totalExpenses).toStringAsFixed(0)}\n\n'
                                    'Uso: ${budgetUsedPercentage.toStringAsFixed(0)}%',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: IncidentCard(
                              count: dashboardProvider.openIncidentsCount,
                              subtitle: 'Abiertas',
                              onTap: () => context.go('/app/incidents'),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                return Consumer<DashboardProvider>(
                  builder: (context, dashboardProvider, _) {
                    final progressPercentage =
                        dashboardProvider.generalProgress * 100;
                    final budgetUsedPercentage =
                        dashboardProvider.budgetUsagePercentage * 100;

                    return Column(
                      children: [
                        CircularProgressCard(
                          title: 'Avance General de Obra',
                          percentage: progressPercentage,
                          subtitle: 'Completado',
                          onTap: () => _showDetailDialog(
                            context,
                            'Avance General de Obra',
                            'Progreso actual: ${progressPercentage.toStringAsFixed(0)}%\n\n'
                                'Este valor se calcula automáticamente basado en el progreso de proyectos activos.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        CostControlCard(
                          title: 'Control de Costos',
                          amount:
                              '\$${dashboardProvider.totalExpenses.toStringAsFixed(0)}',
                          subtitle: 'Gasto Real',
                          currentValue: dashboardProvider.totalExpenses,
                          maxValue: dashboardProvider.totalBudget == 0
                              ? 1
                              : dashboardProvider.totalBudget,
                          onTap: () => _showDetailDialog(
                            context,
                            'Control de Costos',
                            'Presupuesto Total: \$${dashboardProvider.totalBudget.toStringAsFixed(0)}\n'
                                'Gasto Real: \$${dashboardProvider.totalExpenses.toStringAsFixed(0)}\n'
                                'Disponible: \$${(dashboardProvider.totalBudget - dashboardProvider.totalExpenses).toStringAsFixed(0)}\n\n'
                                'Uso: ${budgetUsedPercentage.toStringAsFixed(0)}%',
                          ),
                        ),
                        const SizedBox(height: 16),
                        IncidentCard(
                          count: dashboardProvider.openIncidentsCount,
                          subtitle: 'Abiertas',
                          onTap: () => _showDetailDialog(
                            context,
                            'Incidencias',
                            dashboardProvider.openIncidentsCount == 0
                                ? 'No hay incidencias abiertas en este momento.'
                                : 'Total de incidencias abiertas: ${dashboardProvider.openIncidentsCount}',
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Segunda fila: Progreso del Cronograma y Avance Mensual
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ScheduleProgressCard(
                          status: 'A tiempo',
                          subtitle: 'vs. Planificado',
                          onTap: () => _showDetailDialog(
                            context,
                            'Progreso del Cronograma',
                            'Estado: A tiempo ✓\n\n'
                                'El proyecto está avanzando según lo planificado.\n'
                                'Fecha estimada de finalización: 31/12/2024',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: MonthlyProgressCard(
                          monthlyData: [
                            MonthlyProgress(month: 'Ene', value: 0.6),
                            MonthlyProgress(month: 'Feb', value: 0.7),
                            MonthlyProgress(month: 'Mar', value: 0.75),
                            MonthlyProgress(month: 'Abr', value: 0.8),
                            MonthlyProgress(month: 'May', value: 0.9),
                            MonthlyProgress(
                              month: 'Jun',
                              value: 1.0,
                              isCurrent: true,
                            ),
                            MonthlyProgress(month: 'Jul', value: 0.2),
                          ],
                          onTap: () => _showSnackBar(
                            context,
                            'Ver detalle del avance mensual',
                          ),
                          onBarTap: (data) => _showSnackBar(
                            context,
                            'Mes de ${data.month}: ${(data.value * 100).toStringAsFixed(0)}% de avance',
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ScheduleProgressCard(
                      status: 'A tiempo',
                      subtitle: 'vs. Planificado',
                      onTap: () => _showDetailDialog(
                        context,
                        'Progreso del Cronograma',
                        'Estado: A tiempo ✓\n\n'
                            'El proyecto está avanzando según lo planificado.\n'
                            'Fecha estimada de finalización: 31/12/2024',
                      ),
                    ),
                    const SizedBox(height: 16),
                    MonthlyProgressCard(
                      monthlyData: [
                        MonthlyProgress(month: 'Ene', value: 0.6),
                        MonthlyProgress(month: 'Feb', value: 0.7),
                        MonthlyProgress(month: 'Mar', value: 0.75),
                        MonthlyProgress(month: 'Abr', value: 0.8),
                        MonthlyProgress(month: 'May', value: 0.9),
                        MonthlyProgress(
                          month: 'Jun',
                          value: 1.0,
                          isCurrent: true,
                        ),
                        MonthlyProgress(month: 'Jul', value: 0.2),
                      ],
                      onTap: () => _showSnackBar(
                        context,
                        'Ver detalle del avance mensual',
                      ),
                      onBarTap: (data) => _showSnackBar(
                        context,
                        'Mes de ${data.month}: ${(data.value * 100).toStringAsFixed(0)}% de avance',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
