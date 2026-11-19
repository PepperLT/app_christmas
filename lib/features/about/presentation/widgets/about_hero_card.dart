import 'package:flutter/material.dart';
import 'about_style.dart';

class AboutHeroCard extends StatelessWidget {
  const AboutHeroCard({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: AboutStyle.card.copyWith(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFDF7), Color(0xFFFFEEE4)],
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          const Positioned(
            top: -64,
            right: -64,
            child: _DecorationCircle(color: Color(0xFFF8E2D8)),
          ),
          const Positioned(
            bottom: -80,
            left: -64,
            child: _DecorationCircle(color: Color(0xFFF4E7D3)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: 192,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .8),
                            border: Border.all(color: AboutStyle.border),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/jingle_bells.png',
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          top: 24,
                          child: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFB87A23),
                            size: 24,
                          ),
                        ),
                        const Positioned(
                          right: 0,
                          bottom: 24,
                          child: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFB87A23),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E2CE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'A LITTLE CHRISTMAS MAGIC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF71481C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Christmas\nCountdown',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AboutStyle.primary,
                    fontSize: 36,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: SizedBox(
                    width: 48,
                    child: Divider(
                      height: 8,
                      thickness: 2,
                      color: Color(0xFFBE866A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A little excitement, a little warmth.\nChristmas gets closer every day.',
                  textAlign: TextAlign.center,
                  style: AboutStyle.body,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DecorationCircle extends StatelessWidget {
  const _DecorationCircle({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 176,
    height: 176,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
