import 'package:flutter/material.dart';

import '../../domain/entity/advent_day.dart';

/// Displays a reward after a successful claim, or when viewing it again.
/// Claiming and saving progress remain the controller's responsibility.
class AdventRewardDialog extends StatelessWidget {
  const AdventRewardDialog({
    super.key,
    required this.day,
    this.isNewlyClaimed = false,
  });

  final AdventDay day;
  final bool isNewlyClaimed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imageAsset = day.imageAsset;

    return AlertDialog(
      scrollable: true,
      icon: Icon(Icons.card_giftcard_rounded, color: colors.primary, size: 40),
      title: Text('Ngày ${day.day}: ${day.title}', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAsset != null && imageAsset.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 160,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 80,
                  child: Icon(Icons.image_not_supported_outlined, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(day.message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 32),
          Text(
            isNewlyClaimed
                ? 'Bạn vừa nhận ${day.rewardStars} sao!'
                : 'Đã nhận ${day.rewardStars} sao',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
