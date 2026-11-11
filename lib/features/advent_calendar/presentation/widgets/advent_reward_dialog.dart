import 'package:flutter/material.dart';

import '../../domain/entity/advent_day.dart';

/// Displays an already saved reward, or lets the user view it again.
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
    final imageAsset = day.imageAsset;
    const red = Color(0xFFAD211E);
    const headline = TextStyle(
      color: red,
      fontSize: 25,
      height: 1.25,
      fontWeight: FontWeight.w800,
      shadows: [Shadow(color: Colors.white, offset: Offset(0, 2))],
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight:
              (MediaQuery.sizeOf(context).height -
                      MediaQuery.viewInsetsOf(context).vertical -
                      48)
                  .clamp(0.0, double.infinity),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 84),
                padding: const EdgeInsets.fromLTRB(28, 104, 28, 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: Colors.white, width: 2),
                  gradient: const RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.1,
                    colors: [Color(0xFFFFFEF8), Color(0xFFFFEAE7)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x336B241B),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ngày ${day.day}',
                      textAlign: TextAlign.center,
                      style: headline,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNewlyClaimed ? 'Chúc mừng bạn!' : 'Quà của bạn!',
                      textAlign: TextAlign.center,
                      style: headline,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 132,
                        height: 106,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0xFFFFE8A6), Color(0x00FFE8A6)],
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/star.png',
                          errorBuilder: (_, error, stackTrace) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFBF32),
                            size: 88,
                          ),
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNewlyClaimed
                          ? '+${day.rewardStars} Sao'
                          : 'Đã nhận ${day.rewardStars} Sao',
                      textAlign: TextAlign.center,
                      style: headline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      day.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8F3B30),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (imageAsset != null && imageAsset.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          imageAsset,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                height: 80,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      day.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF986B60),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF57564), Color(0xFFE74D43)],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFB2A0),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26CD4638),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 52),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(isNewlyClaimed ? 'Tuyệt vời!' : 'Đóng'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 40,
                right: 40,
                child: Image.asset(
                  'assets/images/gifd.png',
                  errorBuilder: (_, error, stackTrace) => const SizedBox(
                    height: 174,
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: red,
                      size: 110,
                    ),
                  ),
                  filterQuality: FilterQuality.medium,
                  height: 174,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              Positioned(
                top: 8,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE9CEB5),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x336B241B),
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: 'Đóng',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: red, size: 27),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
