import 'package:flutter/material.dart';

/// Card con gráfico de barras de avance mensual - Optimizado para web
class MonthlyProgressCard extends StatefulWidget {
  const MonthlyProgressCard({super.key, required this.monthlyData, this.onTap, this.onBarTap});

  final List<MonthlyProgress> monthlyData;
  final VoidCallback? onTap;
  final Function(MonthlyProgress)? onBarTap;

  @override
  State<MonthlyProgressCard> createState() => _MonthlyProgressCardState();
}

class _MonthlyProgressCardState extends State<MonthlyProgressCard> {
  bool _isHovered = false;
  int? _hoveredBarIndex;

  @override
  Widget build(BuildContext context) {
    final maxValue = widget.monthlyData.isEmpty
        ? 1.0
        : widget.monthlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

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
                  'Avance Mensual',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.monthlyData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final heightFactor = (data.value / maxValue).clamp(0.1, 1.0);
                      final isCurrent = data.isCurrent;
                      final isHovered = _hoveredBarIndex == index;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: MouseRegion(
                            cursor: widget.onBarTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                            onEnter: (_) => setState(() => _hoveredBarIndex = index),
                            onExit: (_) => setState(() => _hoveredBarIndex = null),
                            child: GestureDetector(
                              onTap: widget.onBarTap != null ? () => widget.onBarTap!(data) : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 1000 + (index * 100)),
                                    tween: Tween<double>(begin: 0.0, end: 140 * heightFactor),
                                    builder: (context, animatedHeight, child) {
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: animatedHeight,
                                        decoration: BoxDecoration(
                                          color: isCurrent ? const Color(0xFFFF8800) : const Color(0xFFFFD4A3),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: isHovered
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        (isCurrent ? const Color(0xFFFF8800) : const Color(0xFFFFD4A3))
                                                            .withValues(alpha: 0.5),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data.month,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrent || isHovered ? const Color(0xFF0A2C52) : const Color(0xFF666666),
                                      fontWeight: isCurrent || isHovered ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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

/// Modelo de datos para avance mensual
class MonthlyProgress {
  final String month;
  final double value;
  final bool isCurrent;

  MonthlyProgress({required this.month, required this.value, this.isCurrent = false});
}
