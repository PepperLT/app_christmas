import 'package:christmas_countdown/features/music/data/local_songs.dart';
import 'package:christmas_countdown/features/music/data/music_player_service.dart';
import 'package:christmas_countdown/features/music/presentation/controllers/song_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'music_player_service_test.dart' show FakePlayer, flush;

void main() {
  test(
    'Opening another detail and closing it leaves shared playback alone',
    () async {
      final player = FakePlayer();
      final service = MusicPlayerService(player: player)..onInit();
      service.toggleSong(localSongs.first);
      service.setPlayMusic(true);
      await flush();
      service.isPlaying.value = true;
      final detail = SongDetailController(song: localSongs[1], service: service)
        ..onInit();
      expect(detail.isPlaying, isFalse);
      expect(detail.canSeek, isFalse);
      expect(detail.visibleDuration, Duration.zero);
      expect(service.selectedSongId.value, localSongs.first.id);
      final starts = player.starts;
      detail.onClose();
      expect(player.starts, starts);
      expect(player.playing, isTrue);
      expect(player.disposed, isFalse);
      service.onClose();
    },
  );

  test('Controller handles switch reminder, play, pause and seek', () async {
    final player = FakePlayer();
    final service = MusicPlayerService(player: player)..onInit();
    final detail = SongDetailController(
      song: localSongs.first,
      service: service,
    )..onInit();
    expect(detail.togglePlayback(), isFalse);
    expect(player.starts, 0);
    service.setPlayMusic(true);
    await flush();
    expect(detail.togglePlayback(), isTrue);
    await flush();
    service.isPlaying.value = true;
    expect(detail.isPlaying, isTrue);
    expect(detail.canSeek, isTrue);
    detail.togglePlayback();
    await flush();
    expect(player.playing, isFalse);
    expect(service.playMusic.value, isTrue);
    service.isPlaying.value = false;
    detail.seekTo(const Duration(seconds: 35));
    await flush();
    expect(player.position, const Duration(seconds: 35));
    expect(player.playing, isTrue);
    detail.onClose();
    service.onClose();
  });
}
