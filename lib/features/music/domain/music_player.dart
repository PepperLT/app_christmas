/// Audio operations required by music, independent of any playback plugin.
abstract interface class MusicPlayer {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<bool> get playingStream;
  Stream<Object> get errorStream;
  Duration get position;
  Duration? get duration;

  /// Loads a bundled asset path or an HTTP(S) audio URL.
  Future<void> load(String source);
  Future<void> loopCurrentSong();
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();
}
