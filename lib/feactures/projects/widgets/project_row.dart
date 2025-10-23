import 'package:flutter/material.dart';
import 'package:strop_admin_panel/domain/projects/project.dart';

typedef OnDelete = void Function(String id);
typedef OnProjectTap = void Function(String id);

class ProjectRow extends StatefulWidget {
  const ProjectRow({
    super.key,
    required this.project,
    required this.onDelete,
    required this.onTap,
  });

  final Project project;
  final OnDelete onDelete;
  final OnProjectTap onTap;

  @override
  State<ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<ProjectRow> {
  bool _isHovered = false;

  Color _progressColor(double percent) {
    if (percent >= 0.75) return const Color(0xFF22C55E); // green
    if (percent >= 0.5) return const Color(0xFFF59E0B); // amber
    return const Color(0xFFEF4444); // red
  }

  // Map status to proper colors and labels like in the mock
  Map<String, Map<String, dynamic>> get _statusMap => {
    'inProgress': {'color': const Color(0xFF22C55E), 'label': 'En Progreso'},
    'completed': {'color': const Color(0xFF6B7280), 'label': 'Finalizado'},
    'onHold': {'color': const Color(0xFFF59E0B), 'label': 'Atención'},
    'planned': {'color': const Color(0xFFEF4444), 'label': 'Retrasado'},
  };

  @override
  Widget build(BuildContext context) {
    final client = (widget.project.toMap()['client'] ?? '') as String? ?? '';
    final rawStatus = widget.project.status.name;
    final statusInfo =
        _statusMap[rawStatus] ??
        {'color': const Color(0xFF22C55E), 'label': 'En Progreso'};
    final badgeColor = statusInfo['color'] as Color;
    final badgeLabel = statusInfo['label'] as String;

    // Calculate progress based on project data
    final progress =
        (widget.project.startDate != null && widget.project.endDate != null)
        ? 0.75
        : 0.4;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.project.id),
        child: Container(
          color: _isHovered
              ? Colors.grey.withValues(alpha: 0.05)
              : Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Project name column
                    Expanded(
                      flex: 4,
                      child: Text(
                        widget.project.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Client column
                    Expanded(
                      flex: 3,
                      child: Text(
                        client.isEmpty ? 'Empresa ABC' : client,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status badge column
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                badgeLabel,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Progress column
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _progressColor(progress),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ],
          ),
        ),
      ),
    );
  }
}
