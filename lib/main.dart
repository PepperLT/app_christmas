import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/advent_calendar/data/advent_progress_service.dart';
import 'features/music/music_dependencies.dart';
import 'features/music/data/firestore_song_repository.dart';
import 'app/christmas_app.dart';
import 'core/services/snowfall_service.dart';
import 'core/services/sound_effects_service.dart';
import 'features/wallpapers/data/wallpaper_service.dart';
import 'features/premium/data/premium_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://llwyaenjtuvabfnfmjbc.supabase.co',
    publishableKey: 'sb_publishable_LCNAvLHTxlwMVRJnIq89fA_JN5mBhel',
  );
  final preferences = await SharedPreferences.getInstance();
  Get.put(PremiumService(), permanent: true);
  Get.put(WallpaperService(preferences: preferences), permanent: true);
  Get.put(SnowfallService(preferences: preferences), permanent: true);
  Get.put(SoundEffectsService(preferences: preferences), permanent: true);
  Get.put(AdventProgressService(preferences), permanent: true);
  Get.put(
    MusicPlayerService(fetchSongs: FirestoreSongRepository().fetchSongs),
    permanent: true,
  );
  runApp(const ChristmasApp());
}
