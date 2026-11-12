import '../core/widget/christmas_drawer.dart';

class AppRoutes {
  static const welcome = '/welcome';
  static const countdown = '/countdown';
  static const music = '/music';
  static const settings = '/settings';
  static const adventCalendar = '/advent-calendar';
  static const bubbleBox = '/bubble-box';
  static const wallpapers = '/wallpapers';
  static const about = '/about';
  static const premium = '/premium';
}

const christmasMenuRoutes = <ChristmasMenuItem, String>{
  ChristmasMenuItem.home: AppRoutes.welcome,
  ChristmasMenuItem.countdown: AppRoutes.countdown,
  ChristmasMenuItem.music: AppRoutes.music,
  ChristmasMenuItem.settings: AppRoutes.settings,
  ChristmasMenuItem.adventCalendar: AppRoutes.adventCalendar,
  ChristmasMenuItem.bubbleBox: AppRoutes.bubbleBox,
  ChristmasMenuItem.wallpapers: AppRoutes.wallpapers,
  ChristmasMenuItem.about: AppRoutes.about,
  ChristmasMenuItem.premium: AppRoutes.premium,
};
