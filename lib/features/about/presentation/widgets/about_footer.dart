import 'package:flutter/material.dart';
import 'about_style.dart';

class AboutFooter extends StatelessWidget {
  const AboutFooter({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        '♥ Made with love for Christmas',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AboutStyle.primary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Wishing you a peaceful and joyful Christmas.',
        textAlign: TextAlign.center,
        style: AboutStyle.body.copyWith(fontSize: 15),
      ),
    ],
  );
}
