import 'package:flutter/material.dart';

/// Card que muestra el número de incidencias - Optimizado para web
class IncidentCard extends StatefulWidget {
  const IncidentCard({
    super.key,
    required this.count,
    required this.subtitle,
    this.onTap,
    this.color = const Color(0xFFFF8800),
    this.critical = 0,
    this.high = 0,
    this.medium = 0,
    this.low = 0,
  });

  final int count;
  final String subtitle;
  final VoidCallback? onTap;
  final Color color;
  // Optional breakdown
  final int critical;
  final int high;
  final int medium;
  final int low;

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Incidencias',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 1000),
                        tween: IntTween(begin: 0, end: widget.count),
                        builder: (context, value, child) {
                          return Text(
                            value.toString(),
                            style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: widget.color, height: 1),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(widget.subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                      const SizedBox(height: 12),
                      // Breakdown
                      if (widget.count > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SeverityPill(label: 'Crit.', value: widget.critical, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            _SeverityPill(label: 'Alta', value: widget.high, color: Colors.orange),
                            const SizedBox(width: 8),
                            _SeverityPill(label: 'Med.', value: widget.medium, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            _SeverityPill(label: 'Baja', value: widget.low, color: Colors.green),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Text(value.toString(), style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
