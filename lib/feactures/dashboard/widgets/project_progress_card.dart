import 'package:flutter/material.dart';

class ProjectProgressCard extends StatelessWidget {
  const ProjectProgressCard({super.key, required this.progress, required this.phase, required this.eta});

  final double progress;
  final String phase;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso del Proyecto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0A2C52)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fase Actual: $phase', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        'Próxima fase: Acabados Interiores',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fecha estimada de finalización: $eta',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                      const SizedBox(height: 6),
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
}
