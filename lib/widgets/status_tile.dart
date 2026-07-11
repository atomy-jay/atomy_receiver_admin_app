import 'package:flutter/material.dart';
import '../theme.dart';

class StatusTile extends StatelessWidget {
  const StatusTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = atomyBlue,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D416B)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: mutedText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
