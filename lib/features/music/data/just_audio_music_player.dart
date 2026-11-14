import 'package:just_audio/just_audio.dart';

import '../domain/music_player.dart';

class JustAudioMusicPlayer implements MusicPlayer {
  JustAudioMusicPlayer({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<Duration> get positionStream => _player.positionStream;
  @override
  Stream<Duration?> get durationStream => _player.durationStream;
  @override
  Stream<bool> get playingStream =>
      _player.playerStateStream.map((state) => state.playing);
  @override
  Stream<Object> get errorStream => _player.errorStream;
  @override
  Duration get position => _player.position;
  @override
  Duration? get duration => _player.duration;

  @override
  Future<void> load(String source) async {
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      await _player.setUrl(source);
    } else {
      await _player.setAsset(source);
    }
  }

  @override
  Future<void> loopCurrentSong() => _player.setLoopMode(LoopMode.one);
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> dispose() => _player.dispose();
}
