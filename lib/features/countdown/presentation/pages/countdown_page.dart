import 'package:christmas_countdown/core/widget/app_menu_button.dart';
import 'package:christmas_countdown/core/widget/christmas_drawer.dart';
import 'package:christmas_countdown/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/countdown_controller.dart';
import '../../../wallpapers/data/wallpaper_service.dart';

class CountdownPage extends GetView<CountdownController> {
  const CountdownPage({super.key});

  static const _textColor = Color(0xFF9E3546);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9E5),
      onDrawerChanged: controller.onDrawerChanged,
      drawer: ChristmasDrawer(
        activeItem: ChristmasMenuItem.countdown,
        routes: christmasMenuRoutes,
        onShare: controller.requestShare,
      ),
      drawerScrimColor: Colors.black54,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            key: controller.screenshotKey,
            child: ColoredBox(
              color: const Color(0xFFFFE9E5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Get.isRegistered<WallpaperService>()
                      ? Obx(
                          () => Image.asset(
                            Get.find<WallpaperService>().selectedAsset.value,
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                            errorBuilder: (_, error, stack) => Image.asset(
                              WallpaperService.defaultAsset,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        )
                      : Image.asset(
                          WallpaperService.defaultAsset,
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                  SafeArea(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 75, 16, 16),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Christmas \nCountdown',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(0, -0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Obx(() {
                                final remaining = controller.remaining.value;

                                if (remaining <= Duration.zero) {
                                  return const Text(
                                    'Merry Christmas!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: _CountdownUnit(
                                        value: remaining.inDays,
                                        label: 'Days',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _CountdownUnit(
                                        value: remaining.inHours % 24,
                                        label: 'Hours',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _CountdownUnit(
                                        value: remaining.inMinutes % 60,
                                        label: 'Minutes',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _CountdownUnit(
                                        value: remaining.inSeconds % 60,
                                        label: 'Seconds',
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 12,
                  child: Builder(
                    builder: (drawerContext) {
                      return AppMenuButton(
                        onPressed: () =>
                            Scaffold.of(drawerContext).openDrawer(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final error = controller.shareError.value;
            if (error == null && !controller.isSharing.value) {
              return const SizedBox.shrink();
            }
            return SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(error ?? 'Đang chuẩn bị ảnh…'),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x249E3546),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Color(0xFF9E3546),
                fontSize: 29,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF74444D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
