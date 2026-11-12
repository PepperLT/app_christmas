import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:christmas_countdown/features/music/data/local_songs.dart';
import 'package:christmas_countdown/features/music/data/music_player_service.dart';
import 'package:christmas_countdown/features/wallpapers/data/wallpaper_service.dart';
import 'package:christmas_countdown/features/premium/data/premium_service.dart';
import 'music_player_service_test.dart' show FakePlayer, flush;

void main() {
  test('Catalog contains two premium songs and nine premium wallpapers', () {
    expect(localSongs.where((s) => s.isPremium).length, 2);
    expect(localSongs.where((s) => !s.isPremium).length, 4);
    expect(WallpaperService.assets.where(WallpaperService.isPremium).length, 9);
    expect(WallpaperService.isPremium(WallpaperService.defaultAsset), isFalse);
    expect(WallpaperService.isPremium(WallpaperService.assets[1]), isFalse);
  });
  test('Premium music cannot select or play without access', () async {
    final player = FakePlayer();
    final music = MusicPlayerService(player: player)..onInit();
    final premium = localSongs.firstWhere((s) => s.isPremium);
    music.setPlayMusic(true);
    music.toggleSong(premium);
    expect(music.playSong(premium), isFalse);
    await flush();
    expect(player.loads, 0);
    expect(music.selectedSongId.value, isNull);
    music.toggleSong(localSongs.first);
    await flush();
    expect(player.loads, 1);
    music.onClose();
  });
  test(
    'Premium wallpaper cannot persist, and old locked selection falls back',
    () async {
      SharedPreferences.setMockInitialValues({
        'countdown_wallpaper': WallpaperService.assets[2],
      });
      final prefs = await SharedPreferences.getInstance();
      final wallpaper = WallpaperService(preferences: prefs);
      expect(wallpaper.selectedAsset.value, WallpaperService.defaultAsset);
      await expectLater(
        wallpaper.select(WallpaperService.assets[2]),
        throwsA(isA<PremiumRequiredException>()),
      );
      expect(wallpaper.selectedAsset.value, WallpaperService.defaultAsset);
      await wallpaper.select(WallpaperService.assets[1]);
      expect(
        prefs.getString('countdown_wallpaper'),
        WallpaperService.assets[1],
      );
    },
  );
}
