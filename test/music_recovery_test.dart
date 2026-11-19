import 'dart:async';
import 'package:christmas_countdown/features/music/domain/entities/song.dart';
import 'package:christmas_countdown/features/music/music_dependencies.dart';
import 'package:christmas_countdown/features/music/presentation/controllers/song_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'music_player_service_test.dart' show FakePlayer, flush;
import 'music_url_playback_test.dart' show UrlPlayer;

const _deadline = Duration(milliseconds: 40);
Song _song(String source, {String id = 'a', String title = 'Song'}) => Song(
  id: id,
  title: title,
  audioPath: source,
  imagePath: 'assets/images/jingle_bells.png',
);

class _LatePlayer extends FakePlayer {
  final loadGate = Completer<void>();
  final positions = StreamController<Duration>.broadcast(sync: true);
  final durations = StreamController<Duration?>.broadcast(sync: true);
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final errors = StreamController<PlayerException>.broadcast(sync: true);
  @override
  Stream<Duration> get positionStream => positions.stream;
  @override
  Stream<Duration?> get durationStream => durations.stream;
  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Stream<PlayerException> get errorStream => errors.stream;
  @override
  Future<Duration?> setAsset(
    String path, {
    bool preload = true,
    String? package,
    Duration? initialPosition,
    dynamic tag,
  }) async {
    loads++;
    await loadGate.future;
    // Simulate an uncooperative native completion, even after disposal.
    asset = path;
    states.add(PlayerState(false, ProcessingState.ready));
    return duration;
  }

  Future<void> closeStreams() async {
    await Future.wait([
      positions.close(),
      durations.close(),
      states.close(),
      errors.close(),
    ]);
  }
}

void main() {
  testWidgets(
    'A timed-out seek cannot move or restart the replacement player when it finishes late',
    (tester) async {
      final old = FakePlayer();
      final replacement = FakePlayer();
      final song = _song('a.mp3');
      final service = MusicPlayerService(
        player: old,
        playerFactory: () => replacement,
        audioTimeout: _deadline,
        initialSongs: [song],
      )..onInit();
      addTearDown(service.onClose);
      service.toggleSong(song);
      service.setPlayMusic(true);
      await tester.pump();
      expect(service.loadedSongId.value, song.id);
      old.pendingSeek = Completer<void>();
      service.seekSong(song, const Duration(seconds: 90));
      await tester.pump();
      expect(service.isSeeking.value, isTrue);
      // Advance the fake clock to the timeout, independent of machine load.
      await tester.pump(_deadline);
      expect(service.isBusy.value, isFalse);
      expect(service.isSeeking.value, isFalse);
      expect(old.disposed, isTrue);
      await service.retry();
      await tester.pump();
      old.pendingSeek!.complete();
      await tester.pump();
      expect(replacement.position, Duration.zero);
      expect(replacement.starts, 1);
      expect(service.error.value, isNull);
    },
  );

  test(
    'Turning music off and selecting another song during a timed-out load never auto-plays stale audio',
    () async {
      final old = _LatePlayer();
      final replacement = FakePlayer();
      final a = _song('a.mp3');
      final b = _song('b.mp3', id: 'b');
      final service = MusicPlayerService(
        player: old,
        playerFactory: () => replacement,
        audioTimeout: _deadline,
        initialSongs: [a, b],
      )..onInit();
      addTearDown(() async {
        service.onClose();
        await old.closeStreams();
      });
      service.toggleSong(a);
      service.setPlayMusic(true);
      await flush();
      service.setPlayMusic(false);
      service.toggleSong(b);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(service.isBusy.value, isFalse);
      expect(replacement.starts, 0);
      expect(service.selectedSongId.value, 'b');
      service.setPlayMusic(true);
      await flush();
      expect(replacement.asset, 'b.mp3');
      expect(replacement.starts, 1);
      old.loadGate.complete();
      await flush();
      expect(old.starts, 0);
      expect(service.loadedSongId.value, 'b');
    },
  );

  test(
    'Catalog source change during an in-flight load starts only the new source',
    () async {
      final player = _LatePlayer();
      var catalog = [_song('old.mp3')];
      final service = MusicPlayerService(
        player: player,
        fetchSongs: () async => catalog,
      )..onInit();
      addTearDown(() async {
        service.onClose();
        await player.closeStreams();
      });
      await service.loadSongs();
      service.toggleSong(catalog.first);
      service.setPlayMusic(true);
      await flush();
      catalog = [_song('new.mp3')];
      await service.loadSongs();
      player.loadGate.complete();
      await flush();
      expect(player.asset, 'new.mp3');
      expect(player.starts, 1);
      expect(service.isBusy.value, isFalse);
    },
  );

  test(
    'Changing asset to URL and changing URL again reloads the actual source with the same ID',
    () async {
      final player = UrlPlayer();
      var catalog = [_song('assets/audio/jingle_bells.mp3')];
      final service = MusicPlayerService(
        player: player,
        fetchSongs: () async => catalog,
      )..onInit();
      addTearDown(service.onClose);
      await service.loadSongs();
      service.toggleSong(catalog.first);
      service.setPlayMusic(true);
      await flush();
      expect(player.asset, catalog.first.audioPath);
      catalog = [_song('https://example.com/a.mp3')];
      await service.loadSongs();
      await flush();
      expect(player.url, catalog.first.audioPath);
      catalog = [_song('https://example.com/b.mp3')];
      await service.loadSongs();
      await flush();
      expect(player.url, catalog.first.audioPath);
      expect(service.loadedSongId.value, 'a');
      expect(player.starts, 3);
    },
  );

  test(
    'Playlist timeout releases loading; Retry is deduplicated and late results are ignored',
    () async {
      final first = Completer<List<Song>>();
      final second = Completer<List<Song>>();
      var calls = 0;
      final service = MusicPlayerService(
        player: FakePlayer(),
        playlistTimeout: _deadline,
        fetchSongs: () => ++calls == 1 ? first.future : second.future,
      )..onInit();
      addTearDown(service.onClose);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(service.isLoadingSongs.value, isFalse);
      expect(service.songsError.value, isNotNull);
      final retry = service.loadSongs();
      expect(identical(retry, service.loadSongs()), isTrue);
      expect(calls, 2);
      second.complete([_song('new.mp3')]);
      await retry;
      first.complete([_song('old.mp3')]);
      await flush();
      expect(service.songs.single.audioPath, 'new.mp3');
      expect(service.songsError.value, isNull);
    },
  );

  test(
    'Late playlist failure after timeout and disposal cannot overwrite state',
    () async {
      final pending = Completer<List<Song>>();
      final service = MusicPlayerService(
        player: FakePlayer(),
        playlistTimeout: _deadline,
        fetchSongs: () => pending.future,
      )..onInit();
      service.onClose();
      pending.completeError(StateError('Late offline failure'));
      await flush();
      expect(service.songs, isEmpty);
      expect(service.songsError.value, isNull);
    },
  );

  test(
    'Audio timeout retires native player and permits another track; old completion is isolated',
    () async {
      final old = _LatePlayer();
      final replacement = _LatePlayer()..loadGate.complete();
      final a = _song('a.mp3');
      final b = _song('b.mp3', id: 'b');
      final service = MusicPlayerService(
        player: old,
        playerFactory: () => replacement,
        audioTimeout: _deadline,
        initialSongs: [a, b],
      )..onInit();
      addTearDown(() async {
        service.onClose();
        await old.closeStreams();
        await replacement.closeStreams();
      });
      final detail = SongDetailController(song: a, service: service)..onInit();
      addTearDown(detail.onClose);
      service.toggleSong(a);
      service.setPlayMusic(true);
      await flush();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(service.isBusy.value, isFalse);
      expect(service.error.value, contains('timed out'));
      expect(old.disposed, isTrue);
      expect(service.loadedSongId.value, isNull);
      service.playSong(b);
      await flush();
      expect(replacement.asset, 'b.mp3');
      expect(replacement.playing, isTrue);
      replacement.positions.add(const Duration(seconds: 7));
      replacement.durations.add(const Duration(minutes: 3));
      replacement.states.add(PlayerState(true, ProcessingState.ready));
      expect(detail.position.value, const Duration(seconds: 7));
      expect(detail.duration.value, const Duration(minutes: 3));
      old.loadGate.complete();
      old.errors.add(PlayerException(1, 'Late native error', null));
      old.positions.add(const Duration(seconds: 99));
      await flush();
      expect(service.loadedSongId.value, 'b');
      expect(replacement.asset, 'b.mp3');
      expect(service.error.value, isNull);
      expect(service.isPlaying.value, isTrue);
      expect(old.starts, 0);
      expect(detail.position.value, isNot(const Duration(seconds: 99)));
    },
  );

  test(
    'Retry after audio timeout reloads the same selected track on a new native player',
    () async {
      final old = _LatePlayer();
      final replacement = FakePlayer();
      final song = _song('a.mp3');
      final service = MusicPlayerService(
        player: old,
        playerFactory: () => replacement,
        audioTimeout: _deadline,
        initialSongs: [song],
      )..onInit();
      addTearDown(() async {
        service.onClose();
        await old.closeStreams();
      });
      service.toggleSong(song);
      service.setPlayMusic(true);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await Future.wait([service.retry(), service.retry(), service.retry()]);
      await flush();
      expect(replacement.loads, 1);
      expect(replacement.asset, song.audioPath);
      expect(service.error.value, isNull);
      old.loadGate.completeError(StateError('Late load error'));
      await flush();
      expect(service.error.value, isNull);
    },
  );

  test(
    'Late load completion after controller disposal never starts audio',
    () async {
      final old = _LatePlayer();
      final service = MusicPlayerService(
        player: old,
        audioTimeout: _deadline,
        initialSongs: [_song('a.mp3')],
      )..onInit();
      service.toggleSong(service.songs.first);
      service.setPlayMusic(true);
      await flush();
      service.onClose();
      old.loadGate.complete();
      await flush();
      expect(old.starts, 0);
      expect(old.disposed, isTrue);
      await old.closeStreams();
    },
  );

  test(
    'Same ID with a changed source reloads audio and updates detail metadata',
    () async {
      var catalog = [_song('old.mp3')];
      final player = FakePlayer();
      final service = MusicPlayerService(
        player: player,
        fetchSongs: () async => catalog,
      )..onInit();
      addTearDown(service.onClose);
      await service.loadSongs();
      final detail = SongDetailController(song: catalog.first, service: service)
        ..onInit();
      addTearDown(detail.onClose);
      service.toggleSong(catalog.first);
      service.setPlayMusic(true);
      await flush();
      catalog = [_song('new.mp3', title: 'Updated')];
      await service.loadSongs();
      await flush();
      expect(player.asset, 'new.mp3');
      expect(detail.song.title, 'Updated');
      expect(detail.song.audioPath, 'new.mp3');
      expect(service.loadedSongId.value, 'a');
      expect(player.loads, 2);
      service.pauseSong(catalog.first);
      await flush();
      catalog = [_song('third.mp3')];
      await service.loadSongs();
      await flush();
      expect(player.playing, isFalse);
      expect(service.loadedSongId.value, isNull);
      service.playSong(catalog.first);
      await flush();
      expect(player.asset, 'third.mp3');
    },
  );

  test(
    'Detail Play retries catalog errors instead of leaving an unrecoverable message',
    () async {
      var fail = false;
      var calls = 0;
      final song = _song('a.mp3');
      final service = MusicPlayerService(
        player: FakePlayer(),
        fetchSongs: () async {
          calls++;
          if (fail) throw StateError('Offline');
          return [song];
        },
      )..onInit();
      addTearDown(service.onClose);
      await service.loadSongs();
      service.toggleSong(song);
      service.setPlayMusic(true);
      await flush();
      final detail = SongDetailController(song: song, service: service)
        ..onInit();
      addTearDown(detail.onClose);
      await service.loadSongs();
      fail = true;
      await service.loadSongs();
      expect(detail.error, isNotNull);
      fail = false;
      final before = calls;
      detail.togglePlayback();
      await flush();
      expect(calls, before + 1);
      expect(detail.error, isNull);
    },
  );
}
