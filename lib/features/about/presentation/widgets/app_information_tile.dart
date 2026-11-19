import 'package:flutter/material.dart';
import 'about_style.dart';

class AppInformationTile extends StatelessWidget {
  const AppInformationTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AboutStyle.accent.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AboutStyle.accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AboutStyle.primary,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(height: 8),
                  Text(value!, style: AboutStyle.body.copyWith(fontSize: 15)),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AboutStyle.primary),
          ],
        ],
      ),
    ),
  );
}
