import 'package:flutter/material.dart';
import 'premium_components.dart';

Future<void> showPremiumDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const PremiumDialog());

class PremiumDialog extends StatelessWidget {
  const PremiumDialog({super.key});
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: PremiumStyle.background,
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PremiumStyle.radius),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 4, top: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      color: PremiumStyle.wine,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Đóng',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: PremiumStyle.wine,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: PremiumContent(onPurchased: () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    ),
  );
}
