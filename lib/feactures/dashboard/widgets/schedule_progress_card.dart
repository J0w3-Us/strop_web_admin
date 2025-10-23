import 'package:flutter/material.dart';

/// Card que muestra progreso del cronograma - Optimizado para web
class ScheduleProgressCard extends StatefulWidget {
  const ScheduleProgressCard({
    super.key,
    required this.status,
    required this.subtitle,
    this.onTap,
    this.color = const Color(0xFF4CAF50),
  });

  final String status;
  final String subtitle;
  final VoidCallback? onTap;
  final Color color;

  @override
  State<ScheduleProgressCard> createState() => _ScheduleProgressCardState();
}

class _ScheduleProgressCardState extends State<ScheduleProgressCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.08),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progreso del Cronograma',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 16),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(fontSize: _isHovered ? 34 : 32, fontWeight: FontWeight.bold, color: widget.color),
                  child: Text(widget.status),
                ),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
