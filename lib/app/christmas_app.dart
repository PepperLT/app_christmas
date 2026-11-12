import 'package:christmas_countdown/features/bubblle_box/presentation/page/bubble_box_page.dart';
import 'package:christmas_countdown/features/settings/presentation/page/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../features/advent_calendar/presentation/page/advent_calendar_page.dart';
import '../features/countdown/presentation/bindings/countdown_binding.dart';
import '../features/countdown/presentation/pages/countdown_page.dart';
import '../features/music/presentation/page/music_page.dart';
import '../features/settings/presentation/bindings/settings_binding.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import '../features/bubblle_box/presentation/bindings/bubble_box_binding.dart';
import 'app_routes.dart';
import '../core/services/snowfall_service.dart';
import '../core/widget/snowfall_overlay.dart';
import '../features/about/presentation/page/about_page.dart';
import '../features/premium/presentation/page/premium_page.dart';
import '../features/wallpapers/presentation/page/wallpapers_page.dart';
import '../features/wallpapers/presentation/bindings/wallpapers_binding.dart';

class ChristmasApp extends StatelessWidget {
  const ChristmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Christmas Countdown',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      builder: (context, child) {
        if (!Get.isRegistered<SnowfallService>()) {
          return child ?? const SizedBox.shrink();
        }
        final snowfall = Get.find<SnowfallService>();
        return Stack(
          fit: StackFit.expand,
          children: [
            child ?? const SizedBox.shrink(),
            Obx(
              () =>
                  snowfall.enabled.value &&
                      !MediaQuery.disableAnimationsOf(context)
                  ? const SnowfallOverlay()
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
      initialRoute: AppRoutes.welcome,
      getPages: [
        GetPage(name: AppRoutes.premium, page: () => const PremiumPage()),
        GetPage(name: AppRoutes.about, page: () => const AboutPage()),
        GetPage(
          name: AppRoutes.wallpapers,
          page: () => const WallpapersPage(),
          binding: WallpapersBinding(),
        ),
        AdventCalendarPage.route,
        GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
        GetPage(
          name: AppRoutes.music,
          page: () => const MusicPage(menuRoutes: christmasMenuRoutes),
        ),
        GetPage(
          name: AppRoutes.countdown,
          page: () => const CountdownPage(),
          binding: CountdownBinding(),
        ),
        GetPage(
          name: AppRoutes.settings,
          page: () => const SettingsPage(),
          binding: SettingsBinding(),
        ),
        GetPage(
          name: AppRoutes.bubbleBox,
          page: () => const BubbleBoxPage(),
          binding: BubbleBoxBinding(),
        ),
      ],
    );
  }
}
