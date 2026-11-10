import 'dart:async';

import 'package:christmas_countdown/features/music/data/local_songs.dart';
import 'package:christmas_countdown/features/music/data/music_player_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

class FakePlayer implements AudioPlayer {
  @override
  bool playing = false;
  bool disposed = false;
  int starts = 0;
  int loads = 0;
  @override
  Duration position = Duration.zero;
  Completer<void>? pendingSeek;
  final seekCalls = <Duration?>[];
  @override
  Duration? get duration => const Duration(minutes: 2);
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration?> get durationStream => const Stream.empty();
  @override
  Future<void> seek(Duration? position, {int? index}) async {
    seekCalls.add(position);
    if (pendingSeek != null) await pendingSeek!.future;
    this.position = position ?? Duration.zero;
  }

  String? asset;
  LoopMode? loop;
  Completer<Duration?>? pendingLoad;
  bool failLoad = false;
  final playback = Completer<void>();

  @override
  Stream<PlayerException> get errorStream => const Stream.empty();
  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();
  @override
  Future<void> stop() async {
    playing = false;
    position = Duration.zero;
  }

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<Duration?> setAsset(
    String path, {
    bool preload = true,
    String? package,
    Duration? initialPosition,
    dynamic tag,
  }) async {
    asset = path;
    loads++;
    if (failLoad) throw StateError('Load failed');
    return pendingLoad == null
        ? const Duration(minutes: 2)
        : pendingLoad!.future;
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    loop = mode;
  }

  @override
  Future<void> play() {
    starts++;
    playing = true;
    return playback.future;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late FakePlayer player;
  late MusicPlayerService service;
  setUp(() {
    player = FakePlayer();
    service = MusicPlayerService(player: player)..onInit();
  });
  tearDown(() => service.onClose());

  test(
    'Rapid seeks apply the latest target after the in-flight seek',
    () async {
      final song = localSongs.first;
      service.toggleSong(song);
      service.setPlayMusic(true);
      await flush();
      final loads = player.loads;
      player.pendingSeek = Completer<void>();
      service.seekSong(song, const Duration(seconds: 20));
      await flush();
      expect(service.isSeeking.value, isTrue);
      service.seekSong(song, const Duration(seconds: 70));
      service.seekSong(song, const Duration(seconds: 40));
      player.pendingSeek!.complete();
      await flush();
      expect(player.seekCalls, [
        const Duration(seconds: 20),
        const Duration(seconds: 40),
      ]);
      expect(player.position, const Duration(seconds: 40));
      expect(player.playing, isTrue);
      expect(player.loads, loads);
      expect(service.isBusy.value, isFalse);
      expect(service.isSeeking.value, isFalse);
    },
  );

  test(
    'Seek forward and backward resumes playback without reloading',
    () async {
      final song = localSongs.first;
      service.toggleSong(song);
      service.setPlayMusic(true);
      await flush();
      final loads = player.loads;
      service.seekSong(song, const Duration(seconds: 80));
      await flush();
      expect(player.position, const Duration(seconds: 80));
      service.pauseSong(song);
      await flush();
      service.seekSong(song, const Duration(seconds: 10));
      await flush();
      expect(player.position, const Duration(seconds: 10));
      expect(player.playing, isTrue);
      expect(player.loads, loads);
      service.seekSong(localSongs[1], const Duration(seconds: 20));
      await flush();
      expect(player.position, const Duration(seconds: 10));
    },
  );

  test(
    'Detail play respects switch and switches to B; pause resumes without loading',
    () async {
      final songA = localSongs.first;
      final songB = localSongs[1];
      expect(service.playSong(songB), isFalse);
      expect(service.selectedSongId.value, isNull);
      service.toggleSong(songA);
      service.setPlayMusic(true);
      await flush();
      expect(service.loadedSongId.value, songA.id);
      service.playSong(songB);
      await flush();
      expect(player.asset, songB.audioPath);
      expect(service.selectedSongId.value, songB.id);
      expect(service.loadedSongId.value, songB.id);
      player.position = const Duration(seconds: 12);
      service.pauseSong(songB);
      await flush();
      expect(player.playing, isFalse);
      expect(service.playMusic.value, isTrue);
      final loads = player.loads;
      service.playSong(songB);
      await flush();
      expect(player.playing, isTrue);
      expect(player.position, const Duration(seconds: 12));
      expect(player.loads, loads);
    },
  );

  test(
    'Switch first waits, selection plays in a loop without awaiting play',
    () async {
      service.setPlayMusic(true);
      await flush();
      expect(service.playMusic.value, isTrue);
      expect(player.starts, 0);
      service.toggleSong(localSongs.first);
      await flush();
      expect(player.playing, isTrue);
      expect(player.asset, localSongs.first.audioPath);
      expect(player.loop, LoopMode.one);
      expect(service.isBusy.value, isFalse);
      service.setPlayMusic(false);
      await flush();
      expect(player.playing, isFalse);
      expect(service.selectedSongId.value, localSongs.first.id);
    },
  );

  test('Selection first waits; deselection stops playback', () async {
    service.toggleSong(localSongs.first);
    await flush();
    expect(player.starts, 0);
    service.setPlayMusic(true);
    await flush();
    expect(player.playing, isTrue);
    service.toggleSong(localSongs.first);
    await flush();
    expect(player.playing, isFalse);
    expect(service.selectedSongId.value, isNull);
  });

  test(
    'Latest input wins during loading without starting stale audio',
    () async {
      player.pendingLoad = Completer<Duration?>();
      service.toggleSong(localSongs.first);
      service.setPlayMusic(true);
      await flush();
      expect(service.isBusy.value, isTrue);
      service.setPlayMusic(false);
      service.setPlayMusic(true);
      service.toggleSong(localSongs.first);
      player.pendingLoad!.complete(const Duration(minutes: 2));
      await flush();
      expect(player.starts, 0);
      expect(service.selectedSongId.value, isNull);
      expect(service.isBusy.value, isFalse);
    },
  );

  test(
    'Failed loading can be retried and disposal releases the player',
    () async {
      player.failLoad = true;
      service.toggleSong(localSongs.first);
      service.setPlayMusic(true);
      await flush();
      expect(service.error.value, isNotNull);
      player.failLoad = false;
      service.retry();
      await flush();
      expect(service.error.value, isNull);
      expect(player.playing, isTrue);
      service.onClose();
      expect(player.disposed, isTrue);
    },
  );
}
