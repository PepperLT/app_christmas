import 'package:flutter/material.dart';

import '../../domain/entity/advent_day.dart';

class AdventDayTile extends StatelessWidget {
  const AdventDayTile({
    super.key,
    required this.day,
    required this.isClaimed,
    required this.canClaim,
    required this.isMissed,
    this.onTap,
  });

  final AdventDay day;
  final bool isClaimed;
  final bool canClaim;
  final bool isMissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = day.dataError != null;
    final enabled = hasError || isClaimed || (canClaim && !isMissed);
    final label = hasError
        ? day.dataError!
        : isClaimed
        ? 'Đã nhận'
        : isMissed
        ? 'Đã bỏ lỡ'
        : canClaim
        ? 'Nhận quà'
        : 'Chưa đến ngày';
    return Semantics(
      label: 'Ngày ${day.day}, $label',
      button: true,
      enabled: onTap != null,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: canClaim ? const Color(0xFFFFDCD0) : const Color(0xFFFFE8E3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: canClaim ? const Color(0xFFEBA54E) : Colors.white70,
              width: canClaim ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomPaint(
                      painter: _GiftPainter(isMissed: isMissed),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      fontSize: 27,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Color(0xFFB5342A),
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasError)
                  const Positioned(
                    right: 5,
                    bottom: 5,
                    child: Icon(
                      Icons.error_outline,
                      color: Color(0xFF923E36),
                      size: 23,
                    ),
                  ),
                if (isClaimed && !hasError)
                  const Positioned(
                    right: 5,
                    bottom: 5,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF2F8554),
                      size: 23,
                    ),
                  ),
                if (!enabled)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Icon(
                      isMissed ? Icons.event_busy : Icons.lock_outline,
                      size: 14,
                      color: const Color(0xFF923E36),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftPainter extends CustomPainter {
  const _GiftPainter({required this.isMissed});
  final bool isMissed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ribbon = Paint()..color = const Color(0xFFFFBA60);
    final bow = Paint()
      ..color = const Color(0xFFFFAA49)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(Rect.fromLTWH(w * .25, h * .05, w * .25, h * .19), bow);
    canvas.drawOval(Rect.fromLTWH(w * .5, h * .05, w * .25, h * .19), bow);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * .1, h * .28, w * .8, h * .68),
      const Radius.circular(7),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, 2)),
      Paint()..color = const Color(0xFFE9B2A3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: isMissed
              ? [const Color(0xFFE8897D), const Color(0xFFD66459)]
              : [const Color(0xFFFF7860), const Color(0xFFDA362F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(body.outerRect),
    );
    canvas.drawRect(Rect.fromLTWH(w * .44, h * .27, w * .12, h * .69), ribbon);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .05, h * .23, w * .9, h * .15),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFFF8A65),
    );
    canvas.drawRect(Rect.fromLTWH(w * .44, h * .23, w * .12, h * .15), ribbon);
  }

  @override
  bool shouldRepaint(_GiftPainter oldDelegate) =>
      isMissed != oldDelegate.isMissed;
}
