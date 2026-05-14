import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 12),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5)),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    )));
  }
}
