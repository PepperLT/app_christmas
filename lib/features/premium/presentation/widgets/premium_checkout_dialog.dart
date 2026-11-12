import 'package:flutter/material.dart';
import '../../domain/premium_plan.dart';
import 'premium_components.dart';

/// Shared confirmation surface for the selected plan.
class PremiumCheckoutDialog extends StatelessWidget {
  const PremiumCheckoutDialog({super.key, required this.plan});
  final PremiumPlan plan;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: PremiumStyle.background,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PremiumStyle.radius),
    ),
    scrollable: true,
    icon: const Icon(
      Icons.workspace_premium_rounded,
      size: 44,
      color: Color(0xFFB97C24),
    ),
    title: const Text(
      'Xác nhận gói Premium',
      textAlign: TextAlign.center,
      style: TextStyle(color: PremiumStyle.wine, fontWeight: FontWeight.w800),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumPlanCard(plan: plan, selected: true, showPeriod: true),
        const SizedBox(height: 16),
        const Text(
          'Mở khóa nhạc và hình nền Premium.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PremiumStyle.body, height: 1.5),
        ),
        const SizedBox(height: 12),
        const Text(
          'Đây là giá dự kiến. Cửa hàng thanh toán chưa được kết nối nên hiện chưa thể thực hiện giao dịch.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PremiumStyle.body, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        const PremiumActionButton(
          label: 'Thanh toán — chưa khả dụng',
          icon: Icons.lock_outline_rounded,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Quay lại',
          style: TextStyle(color: PremiumStyle.wine),
        ),
      ),
    ],
  );
}
