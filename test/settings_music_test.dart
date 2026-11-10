import 'dart:io';

import 'package:christmas_countdown/app/app_routes.dart';
import 'package:christmas_countdown/app/christmas_app.dart';
import 'package:christmas_countdown/features/music/data/local_songs.dart';
import 'package:christmas_countdown/features/music/data/music_player_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'music_player_service_test.dart' show FakePlayer;

class _TestAssets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/images/footer_0.png') {
      return ByteData.sublistView(File(key).readAsBytesSync());
    }
    return rootBundle.load(key);
  }
}

void main() {
  testWidgets('Settings and Santa Songs share music state across routes', (
    tester,
  ) async {
    Get.testMode = true;
    final player = FakePlayer();
    final service = Get.put(
      MusicPlayerService(player: player),
      permanent: true,
    );
    service.toggleSong(localSongs.first);
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: _TestAssets(), child: const ChristmasApp()),
    );
    await tester.pumpAndSettle();
    Get.offNamed(AppRoutes.settings);
    await tester.pumpAndSettle();
    final settingsSwitch = find.widgetWithText(SwitchListTile, 'Music');
    expect(tester.widget<SwitchListTile>(settingsSwitch).value, isFalse);
    await tester.tap(settingsSwitch);
    await tester.pumpAndSettle();
    expect(player.playing, isTrue);
    Get.offNamed(AppRoutes.music);
    await tester.pumpAndSettle();
    final musicSwitch = find.widgetWithText(SwitchListTile, 'Play Music');
    expect(tester.widget<SwitchListTile>(musicSwitch).value, isTrue);
    expect(Get.find<MusicPlayerService>(), same(service));
    await tester.tap(musicSwitch);
    await tester.pumpAndSettle();
    expect(player.playing, isFalse);
    expect(service.selectedSongId.value, localSongs.first.id);
    Get.offNamed(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(settingsSwitch).value, isFalse);
    expect(Get.find<MusicPlayerService>(), same(service));
    expect(player.disposed, isFalse);
    service.onClose();
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });
}
