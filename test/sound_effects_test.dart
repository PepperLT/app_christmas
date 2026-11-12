import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:christmas_countdown/core/services/sound_effects_service.dart';
import 'package:christmas_countdown/features/bubblle_box/presentation/controller/bubble_box_controller.dart';
import 'music_player_service_test.dart' show FakePlayer, flush;

void main() {
  test('Sound setting persists and mute stops playback', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final player = FakePlayer();
    final service = SoundEffectsService(preferences: prefs, player: player);
    service.play(SoundEffect.merge);
    await flush();
    expect(player.asset, SoundEffect.merge.asset);
    expect(player.starts, 1);
    await service.setEnabled(false);
    await flush();
    expect(player.playing, isFalse);
    service.play(SoundEffect.reward);
    await flush();
    expect(player.starts, 1);
    final restored = SoundEffectsService(
      preferences: prefs,
      player: FakePlayer(),
    );
    expect(restored.enabled.value, isFalse);
    restored.onClose();
    service.onClose();
  });

  test(
    'Rapid requests use latest effect and asset errors are contained',
    () async {
      final player = FakePlayer()..pendingLoad = Completer();
      final service = SoundEffectsService(player: player);
      service.play(SoundEffect.merge);
      await flush();
      service.play(SoundEffect.reward);
      player.pendingLoad!.complete(null);
      await flush();
      await flush();
      expect(player.asset, SoundEffect.reward.asset);
      expect(player.starts, 1);
      player.failLoad = true;
      service.play(SoundEffect.rescue);
      await flush();
      expect(player.starts, 1);
      service.onClose();
    },
  );

  test('Bubble Box plays effects only for successful actions', () async {
    final player = FakePlayer();
    final service = Get.put(SoundEffectsService(player: player));
    final controller = BubbleBoxController()..onInit();
    final cells = controller.cells;
    final from = cells.indexWhere((e) => e != null);
    final wrong = cells.indexWhere(
      (e) => e != null && e.type != cells[from]!.type,
    );
    controller.selectCell(from);
    controller.selectCell(wrong);
    await flush();
    expect(player.starts, 0);
    final to = cells.indexWhere(
      (e) =>
          e != null &&
          e.type == cells[from]!.type &&
          !identical(e, cells[from]),
    );
    controller.selectCell(from);
    controller.selectCell(to);
    await flush();
    expect(player.asset, SoundEffect.merge.asset);
    expect(player.starts, 1);
    controller.rescueBoard();
    await flush();
    expect(player.asset, SoundEffect.rescue.asset);
    expect(player.starts, 2);
    controller.rescueBoard();
    await flush();
    expect(player.starts, 2);
    controller.onClose();
    service.onClose();
    Get.reset();
  });
}
