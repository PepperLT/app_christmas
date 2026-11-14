import 'package:christmas_countdown/features/music/music_dependencies.dart';
import 'package:christmas_countdown/features/music/domain/entities/song.dart';
import 'package:flutter_test/flutter_test.dart';

import 'music_player_service_test.dart' show FakePlayer, flush;

class UrlPlayer extends FakePlayer {
  String? url;

  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    this.url = url;
    return const Duration(minutes: 2);
  }
}

void main() {
  test(
    'URL catalog song plays and resumes without loading a bundled asset',
    () async {
      const song = Song(
        id: 'remote',
        title: 'Remote song',
        imagePath: 'assets/images/jingle_bells.png',
        audioPath:
            'https://llwyaenjtuvabfnfmjbc.supabase.co/storage/v1/object/public/music/jingle_bells.mp3',
      );
      final player = UrlPlayer();
      final service = MusicPlayerService(player: player, initialSongs: [song])
        ..onInit();
      addTearDown(service.onClose);
      service.toggleSong(song);
      service.setPlayMusic(true);
      await flush();
      expect(player.url, song.audioPath);
      expect(player.asset, isNull);
      expect(service.loadedSongId.value, song.id);
      expect(player.playing, isTrue);
      service.pauseSong(song);
      await flush();
      expect(player.playing, isFalse);
      service.playSong(song);
      await flush();
      expect(player.playing, isTrue);
      expect(player.loads, 0);
    },
  );
}
