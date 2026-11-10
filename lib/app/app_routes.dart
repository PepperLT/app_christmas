import '../core/widget/christmas_drawer.dart';

class AppRoutes {
  static const welcome = '/welcome';
  static const countdown = '/countdown';
  static const music = '/music';
  static const settings = '/settings';
  static const adventCalendar = '/advent-calendar';
}

const christmasMenuRoutes = <ChristmasMenuItem, String>{
  ChristmasMenuItem.home: AppRoutes.welcome,
  ChristmasMenuItem.countdown: AppRoutes.countdown,
  ChristmasMenuItem.music: AppRoutes.music,
  ChristmasMenuItem.settings: AppRoutes.settings,
  ChristmasMenuItem.adventCalendar: AppRoutes.adventCalendar,
};
