import 'dart:io';

import 'package:christmas_countdown/app/app_routes.dart';
import 'package:christmas_countdown/app/christmas_app.dart';
import 'fixtures/local_songs.dart';
import 'package:christmas_countdown/features/music/music_dependencies.dart';
import 'package:christmas_countdown/features/music/presentation/page/music_page.dart';
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
  testWidgets('Pull to refresh reloads even an empty song catalog', (
    tester,
  ) async {
    Get.testMode = true;
    var requests = 0;
    Get.put(
      MusicPlayerService(
        player: FakePlayer(),
        fetchSongs: () async {
          requests++;
          return [];
        },
      ),
    );
    await tester.pumpWidget(
      const GetMaterialApp(home: MusicPage(menuRoutes: {})),
    );
    await tester.pumpAndSettle();
    expect(requests, 1);
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(requests, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });

  testWidgets('Settings and Santa Songs share music state across routes', (
    tester,
  ) async {
    Get.testMode = true;
    final player = FakePlayer();
    final service = Get.put(
      MusicPlayerService(player: player, initialSongs: localSongs),
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
