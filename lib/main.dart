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
import 'dart:developer' as developer;
import 'app/startup_app.dart';
import 'app/startup_initializer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;
  final initializer = StartupInitializer(
    essential: [
      StartupStep('Firebase', () async {
        if (!Firebase.apps.any((app) => app.name == '[DEFAULT]')) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
      }),
      StartupStep('Preferences', () async {
        preferences = await SharedPreferences.getInstance();
      }),
      StartupStep('App services', () async {
        await _register(() => PremiumService());
        await _register(() => WallpaperService(preferences: preferences));
        await _register(() => SnowfallService(preferences: preferences));
        await _register(() => SoundEffectsService(preferences: preferences));
        await _register(() => AdventProgressService(preferences));
        await _register(
          () => MusicPlayerService(
            fetchSongs: FirestoreSongRepository().fetchSongs,
          ),
        );
      }),
    ],
    optional: [
      StartupStep('Supabase', () async {
        await Supabase.initialize(
          url: 'https://llwyaenjtuvabfnfmjbc.supabase.co',
          publishableKey: 'sb_publishable_LCNAvLHTxlwMVRJnIq89fA_JN5mBhel',
        );
      }),
    ],
    onOptionalError: (name, error, stack) => developer.log(
      '$name initialization failed',
      name: 'startup',
      error: error,
      stackTrace: stack,
    ),
  );
  runApp(
    StartupApp(
      initializer: initializer,
      appBuilder: (_) => const ChristmasApp(),
    ),
  );
}

Future<void> _register<T>(T Function() create) async {
  if (Get.isRegistered<T>()) return;
  try {
    Get.put<T>(create(), permanent: true);
  } catch (_) {
    await Get.delete<T>(force: true);
    rethrow;
  }
}
