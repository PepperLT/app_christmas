import 'dart:async';

import 'package:get/get.dart';

import 'music_controller.dart';
import '../../domain/entities/song.dart';

class SongDetailController extends GetxController {
  SongDetailController({required Song song, required MusicController service})
    : _song = song.obs,
      _service = service;

  final Rx<Song> _song;
  Song get song => _song.value;
  final MusicController _service;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  bool get canAccess {
    final latest = _service.songs.where((item) => item.id == song.id);
    return _service.canAccess(latest.isEmpty ? song : latest.first);
  }

  bool get isBusy => _service.isBusy.value || _service.isLoadingSongs.value;
  bool get canGoNext => !isBusy && _service.nextSongOf(song) != null;
  bool get canGoPrevious => !isBusy && _service.previousSongOf(song) != null;
  bool get isActive => _service.loadedSongId.value == song.id;
  bool get isPlaying => isActive && _service.isPlaying.value;
  bool get isLoadingSong => _service.loadingSongId.value == song.id;
  String? get error => _service.songsError.value ?? _service.error.value;
  bool get canSeek =>
      (!isBusy || _service.isSeeking.value) &&
      isActive &&
      _service.playMusic.value &&
      error == null &&
      duration.value > Duration.zero;
  Duration get visiblePosition => isActive ? position.value : Duration.zero;
  Duration get visibleDuration => isActive ? duration.value : Duration.zero;

  @override
  void onInit() {
    super.onInit();
    position.value = _service.position;
    duration.value = _service.duration ?? Duration.zero;
    _positionSubscription = _service.positionStream.listen((value) {
      position.value = value;
    });
    _durationSubscription = _service.durationStream.listen((value) {
      duration.value = value ?? Duration.zero;
    });
  }

  // False asks the view to show the Play Music reminder.
  bool togglePlayback() {
    if (isBusy) return true;
    if (isPlaying) {
      _service.pauseSong(song);
      return true;
    }
    return _service.playSong(song);
  }

  void seekTo(Duration value) {
    if (canSeek) _service.seekSong(song, value);
  }

  // False asks the view to show the Play Music reminder.
  bool nextSong() => _switchSong(_service.nextSongOf(song));

  bool previousSong() => _switchSong(_service.previousSongOf(song));

  bool _switchSong(Song? target) {
    if (isClosed || isBusy || target == null) return true;
    if (!_service.playSong(target)) return false;
    _song.value = target;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    return true;
  }

  @override
  void onClose() {
    unawaited(_positionSubscription?.cancel());
    unawaited(_durationSubscription?.cancel());
    // The app owns the player; closing this screen only removes listeners.
    super.onClose();
  }
}
