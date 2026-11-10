import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/music/data/music_player_service.dart';
import 'app/christmas_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(MusicPlayerService(), permanent: true);
  runApp(const ChristmasApp());
}
