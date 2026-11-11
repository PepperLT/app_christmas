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

class ChristmasApp extends StatelessWidget {
  const ChristmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Christmas Countdown',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.welcome,
      getPages: [
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
