import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/premium_service.dart';
import '../../domain/premium_plan.dart';
import 'premium_checkout_dialog.dart';

abstract final class PremiumStyle {
  static const wine = Color(0xFF742733);
  static const body = Color(0xFF66504F);
  static const red = Color(0xFFD0444D);
  static const background = Color(0xFFFFF8F4);
  static const radius = 26.0;
}

/// Used on the Premium page and in every locked-content dialog.
class PremiumContent extends StatelessWidget {
  const PremiumContent({super.key, this.onPurchased});
  final VoidCallback? onPurchased;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      LayoutBuilder(
        builder: (context, constraints) => AspectRatio(
          aspectRatio: 1816 / 866,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/header.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                errorBuilder: (_, error, stack) =>
                    const ColoredBox(color: Color(0xFFFFDEE1)),
              ),
              Positioned(
                top: constraints.maxWidth * .065,
                left: constraints.maxWidth * .46,
                right: 12,
                child: Text(
                  'Mở khóa\nChristmas Premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PremiumStyle.wine,
                    fontSize: constraints.maxWidth < 340 ? 18 : 23,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Benefit(
              icon: Icons.music_note_rounded,
              title: 'Mở khóa các bài nhạc Premium',
              description: 'Thưởng thức trọn bộ giai điệu Giáng sinh.',
            ),
            const SizedBox(height: 18),
            const _Benefit(
              icon: Icons.image_outlined,
              title: 'Trọn bộ các hình nền Premium',
              description: 'Làm mới màn hình Countdown theo cách của bạn.',
            ),
            const SizedBox(height: 24),
            PremiumOffer(onPurchased: onPurchased),
            const SizedBox(height: 8),
            const Text(
              'Bạn vẫn có thể tận hưởng nhạc và hình nền miễn phí như bình thường.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PremiumStyle.body,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Image.asset(
        'assets/images/footer.png',
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        excludeFromSemantics: true,
      ),
    ],
  );
}

class PremiumOffer extends StatefulWidget {
  const PremiumOffer({super.key, this.onPurchased});
  final VoidCallback? onPurchased;
  @override
  State<PremiumOffer> createState() => _PremiumOfferState();
}

class _PremiumOfferState extends State<PremiumOffer> {
  late final PremiumService _service = PremiumService.instance;
  bool _checkoutOpen = false;

  Future<void> _openCheckout() async {
    if (_checkoutOpen) return;
    _checkoutOpen = true;
    final plan = _service.selectedPlan.value;
    try {
      final purchased = await showDialog<bool>(
        context: context,
        builder: (_) => PremiumCheckoutDialog(plan: plan),
      );
      if (mounted && purchased == true) widget.onPurchased?.call();
    } finally {
      _checkoutOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = _service.selectedPlan.value;
    final active = _service.hasPremium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Christmas Premium',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PremiumStyle.red,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final plan in PremiumPlan.values) ...[
              if (plan != PremiumPlan.values.first) const SizedBox(width: 12),
              Expanded(
                child: PremiumPlanCard(
                  plan: plan,
                  selected: plan == selected,
                  onTap: () => _service.selectPlan(plan),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          active
              ? 'Cảm ơn bạn đã đồng hành!'
              : 'Giá dự kiến. Thanh toán chưa khả dụng.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: PremiumStyle.body,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        PremiumActionButton(
          onPressed: active ? null : _openCheckout,
          icon: active
              ? Icons.check_circle_outline
              : Icons.lock_outline_rounded,
          label: active ? 'Đã mở khóa Premium' : 'Tiếp tục thanh toán',
        ),
        if (!active)
          const TextButton(
            onPressed: null,
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(PremiumStyle.body),
            ),
            child: Text(
              'Khôi phục giao dịch — chưa khả dụng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  });
}

class PremiumPlanCard extends StatelessWidget {
  const PremiumPlanCard({
    super.key,
    required this.plan,
    required this.selected,
    this.onTap,
    this.showPeriod = false,
  });
  final PremiumPlan plan;
  final bool selected;
  final VoidCallback? onTap;
  final bool showPeriod;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: onTap != null,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [const Color(0xFFFFF4DD), const Color(0xFFFFE8D3)]
                  : [const Color(0xFFFFF0ED), const Color(0xFFFCE2E1)],
            ),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF39741)
                  : const Color(0xFFF5C7C4),
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFAB6A27),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Flexible(
                    child: Text(
                      plan.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PremiumStyle.wine,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                showPeriod ? plan.priceWithPeriod : plan.price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? PremiumStyle.red : PremiumStyle.wine,
                  fontSize: showPeriod ? 27 : 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PremiumActionButton extends StatelessWidget {
  const PremiumActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF37875), Color(0xFFDF5356)],
      ),
      border: Border.all(color: const Color(0xFFFFB4A6), width: 1.5),
    ),
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, textAlign: TextAlign.center),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: const StadiumBorder(),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: PremiumStyle.red, size: 28),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2C2530),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: PremiumStyle.body,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
