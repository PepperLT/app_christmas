import 'package:flutter/material.dart';
import 'about_feature_tile.dart';
import 'about_style.dart';

class AboutFeaturesSection extends StatelessWidget {
  const AboutFeaturesSection({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'App Features',
        textAlign: TextAlign.center,
        style: AboutStyle.heading,
      ),
      const SizedBox(height: 16),
      DecoratedBox(
        decoration: AboutStyle.card,
        child: const Column(
          children: [
            AboutFeatureTile(
              icon: Icons.timer_outlined,
              title: 'Waiting for Christmas',
              description:
                  'Count down the days, hours, minutes, and seconds until the festive season.',
              color: Color(0xFFA73E4C),
            ),
            _FeatureDivider(),
            AboutFeatureTile(
              icon: Icons.card_giftcard_rounded,
              title: 'A Gift Every Day',
              description: 'Explore the Advent Calendar from December 1 to 25.',
              color: Color(0xFF98601A),
            ),
            _FeatureDivider(),
            AboutFeatureTile(
              icon: Icons.music_note_rounded,
              title: 'Music & Joy',
              description:
                  'Enjoy Christmas music and merge items in the Bubble Box mini-game.',
              color: Color(0xFF316B55),
            ),
            _FeatureDivider(),
            AboutFeatureTile(
              icon: Icons.wallpaper_rounded,
              title: 'Christmas Your Way',
              description:
                  'Choose your Countdown wallpaper and enable snowfall in Settings.',
              color: Color(0xFF71508E),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    indent: 16,
    endIndent: 16,
    color: AboutStyle.border,
  );
}
