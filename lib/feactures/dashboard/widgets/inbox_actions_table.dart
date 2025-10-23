import 'package:flutter/material.dart';

class InboxItem {
  InboxItem({required this.priority, required this.task, required this.project, required this.priorityColor});

  final String priority;
  final String task;
  final String project;
  final Color priorityColor;
}


/// Simple inbox/list for actions — design-only UI used in the redesigned dashboard
class InboxActionsTable extends StatelessWidget {
  const InboxActionsTable({super.key, required this.items});

  final List<InboxItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bandeja de Entrada: Acciones Urgentes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0A2C52)),
          ),
          const SizedBox(height: 12),
          // Use ListTiles for a simple readable list (design-only)
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                tileColor: Colors.white,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: it.priorityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(it.priority, style: TextStyle(color: it.priorityColor, fontWeight: FontWeight.w600)),
                ),
                title: Text(it.task),
                subtitle: Text(it.project, style: const TextStyle(color: Color(0xFF666666))),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8800)),
                  child: const Text('Ver Detalle'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}