import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/advent_calendar/data/advent_progress_service.dart';
import 'features/music/data/music_player_service.dart';
import 'app/christmas_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  Get.put(AdventProgressService(preferences), permanent: true);
  Get.put(MusicPlayerService(), permanent: true);
  runApp(const ChristmasApp());
}
