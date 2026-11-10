import 'dart:async';

import 'package:get/get.dart';

import '../../data/music_player_service.dart';
import '../../domain/entities/song.dart';

class SongDetailController extends GetxController {
  SongDetailController({
    required this.song,
    required MusicPlayerService service,
  }) : _service = service;

  final Song song;
  final MusicPlayerService _service;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  bool get isBusy => _service.isBusy.value;
  bool get isActive => _service.loadedSongId.value == song.id;
  bool get isPlaying => isActive && _service.isPlaying.value;
  bool get isLoadingSong => _service.loadingSongId.value == song.id;
  String? get error => _service.error.value;
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

  @override
  void onClose() {
    unawaited(_positionSubscription?.cancel());
    unawaited(_durationSubscription?.cancel());
    // The app owns the player; closing this screen only removes listeners.
    super.onClose();
  }
}
