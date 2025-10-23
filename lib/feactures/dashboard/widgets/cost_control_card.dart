import 'package:flutter/material.dart';

class CostControlCard extends StatefulWidget {
  const CostControlCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.currentValue,
    required this.maxValue,
    this.onTap,
  });

  final String title;
  final String amount;
  final String subtitle;
  final double currentValue;
  final double maxValue;
  final VoidCallback? onTap;

  @override
  State<CostControlCard> createState() => _CostControlCardState();
}

class _CostControlCardState extends State<CostControlCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final percentage = widget.maxValue == 0
        ? 0.0
        : (widget.currentValue / widget.maxValue).clamp(0.0, 1.0);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
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
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.amount,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2C52),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2C52),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8800),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '\$0',
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                    Text(
                      '\$${widget.maxValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
