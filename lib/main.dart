import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/advent_calendar/data/advent_progress_service.dart';
import 'features/music/data/music_player_service.dart';
import 'app/christmas_app.dart';
import 'core/services/snowfall_service.dart';
import 'core/services/sound_effects_service.dart';
import 'features/wallpapers/data/wallpaper_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  Get.put(WallpaperService(preferences: preferences), permanent: true);
  Get.put(SnowfallService(preferences: preferences), permanent: true);
  Get.put(SoundEffectsService(preferences: preferences), permanent: true);
  Get.put(AdventProgressService(preferences), permanent: true);
  Get.put(MusicPlayerService(), permanent: true);
  runApp(const ChristmasApp());
}
