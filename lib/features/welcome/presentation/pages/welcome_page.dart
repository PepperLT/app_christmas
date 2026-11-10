import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.offNamed(AppRoutes.countdown),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/welcome_background.png',
              fit: BoxFit.cover,
            ),
            const Positioned(
              top: 64,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Text(
                  'Christmas\nCountdown',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFF8F0),
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.05,
                    shadows: [
                      Shadow(
                        color: Color(0x55000000),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
