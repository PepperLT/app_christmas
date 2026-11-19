import 'dart:async';
import 'dart:developer' as developer;
import 'package:just_audio/just_audio.dart';

import '../domain/music_player.dart';

class JustAudioMusicPlayer implements MusicPlayer {
  JustAudioMusicPlayer({
    AudioPlayer? player,
    AudioPlayer Function()? playerFactory,
  }) : _factory = playerFactory ?? (() => AudioPlayer()) {
    _attach(player ?? _factory());
  }

  final AudioPlayer Function() _factory;
  AudioPlayer? _player;
  int _generation = 0;
  bool _closed = false;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _positions = StreamController<Duration>.broadcast(sync: true);
  final _durations = StreamController<Duration?>.broadcast(sync: true);
  final _playing = StreamController<bool>.broadcast(sync: true);
  final _errors = StreamController<Object>.broadcast(sync: true);

  AudioPlayer get _active {
    if (_closed) throw StateError('Music player is closed');
    if (_player == null) _attach(_factory());
    return _player!;
  }

  void _attach(AudioPlayer player) {
    _player = player;
    final generation = ++_generation;
    void forwardError(Object error) {
      if (!_closed && generation == _generation) _errors.add(error);
    }

    _subscriptions.addAll([
      player.positionStream.listen((value) {
        if (!_closed && generation == _generation) _positions.add(value);
      }, onError: forwardError),
      player.durationStream.listen((value) {
        if (!_closed && generation == _generation) _durations.add(value);
      }, onError: forwardError),
      player.playerStateStream.listen((value) {
        if (!_closed && generation == _generation) _playing.add(value.playing);
      }, onError: forwardError),
      player.errorStream.listen(forwardError, onError: forwardError),
    ]);
  }

  AudioPlayer? _detach() {
    ++_generation;
    final previous = _player;
    _player = null;
    for (final subscription in _subscriptions) {
      unawaited(_cancelSubscription(subscription));
    }
    _subscriptions.clear();
    return previous;
  }

  Future<void> _cancelSubscription(
    StreamSubscription<dynamic> subscription,
  ) async {
    try {
      await subscription.cancel();
    } catch (error, stack) {
      developer.log(
        'Audio subscription cleanup failed',
        name: 'music',
        error: error,
        stackTrace: stack,
      );
    }
  }

  Future<void> _disposeNative(AudioPlayer player) async {
    try {
      // A retired native player is never reused, even if its cleanup fails.
      await player.dispose().timeout(const Duration(seconds: 5));
    } catch (error, stack) {
      developer.log(
        'Retired audio player cleanup failed',
        name: 'music',
        error: error,
        stackTrace: stack,
      );
    }
  }

  @override
  Stream<Duration> get positionStream => _positions.stream;
  @override
  Stream<Duration?> get durationStream => _durations.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Stream<Object> get errorStream => _errors.stream;
  @override
  Duration get position => _player?.position ?? Duration.zero;
  @override
  Duration? get duration => _player?.duration;

  @override
  Future<void> load(String source) async {
    final player = _active;
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      await player.setUrl(source);
    } else {
      await player.setAsset(source);
    }
  }

  @override
  Future<void> loopCurrentSong() => _active.setLoopMode(LoopMode.one);
  @override
  Future<void> play() => _active.play();
  @override
  Future<void> pause() => _active.pause();
  @override
  Future<void> stop() => _active.stop();
  @override
  Future<void> seek(Duration position) => _active.seek(position);

  @override
  Future<void> reset() async {
    if (_closed) return;
    final previous = _detach();
    if (previous != null) unawaited(_disposeNative(previous));
    _positions.add(Duration.zero);
    _durations.add(null);
    _playing.add(false);
    _attach(_factory());
  }

  @override
  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    final previous = _detach();
    final cleanup = previous == null
        ? Future<void>.value()
        : _disposeNative(previous);
    await Future.wait([
      cleanup,
      _positions.close(),
      _durations.close(),
      _playing.close(),
      _errors.close(),
    ]);
  }
}
