import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'local_songs.dart';
import '../domain/entities/song.dart';
import '../../premium/data/premium_service.dart';

class MusicPlayerService extends GetxService {
  MusicPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  final playMusic = false.obs;
  final selectedSongId = RxnString();
  final isBusy = false.obs;
  final isSeeking = false.obs;
  final error = RxnString();
  final isPlaying = false.obs;
  final loadedSongId = RxnString();
  final loadingSongId = RxnString();
  bool _pauseRequested = false;
  bool _resumeRequested = false;
  Duration? _seekPosition;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool canAccess(Song song) => !song.isPremium || PremiumService.isUnlocked;

  void seekSong(Song song, Duration position) {
    if (_closed ||
        !canAccess(song) ||
        (isBusy.value && !isSeeking.value) ||
        !playMusic.value ||
        loadedSongId.value != song.id ||
        error.value != null) {
      return;
    }
    final total = _player.duration;
    if (total == null || total <= Duration.zero) return;
    final milliseconds = position.inMilliseconds.clamp(0, total.inMilliseconds);
    _pauseRequested = false;
    _requestPlayback(resume: true, seek: Duration(milliseconds: milliseconds));
  }

  int _revision = 0;
  bool _closed = false;
  StreamSubscription<PlayerException>? _errors;
  StreamSubscription<PlayerState>? _states;
  StreamSubscription<bool>? _premiumChanges;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PremiumService>()) {
      _premiumChanges = Get.find<PremiumService>().accessChanges.listen((_) {
        final selected = localSongs.where(
          (song) => song.id == selectedSongId.value,
        );
        if (!_closed && selected.isNotEmpty && !canAccess(selected.first)) {
          selectedSongId.value = null;
          _requestPlayback();
        }
      });
    }
    _errors = _player.errorStream.listen((exception) {
      if (!_closed && playMusic.value && selectedSongId.value != null) {
        error.value = 'Không thể phát nhạc. Vui lòng thử lại.';
      }
    });
    _states = _player.playerStateStream.listen((state) {
      if (!_closed) isPlaying.value = state.playing;
    });
  }

  void setPlayMusic(bool enabled) {
    if (_closed) return;
    playMusic.value = enabled;
    _pauseRequested = false;
    _requestPlayback();
  }

  void toggleSong(Song song) {
    if (_closed || !canAccess(song)) return;
    selectedSongId.value = selectedSongId.value == song.id ? null : song.id;
    _pauseRequested = false;
    _requestPlayback();
  }

  void retry() {
    if (!_closed) {
      _pauseRequested = false;
      _requestPlayback();
    }
  }

  // Returns false when the app-wide music switch is off.
  bool playSong(Song song) {
    if (_closed || !playMusic.value || !canAccess(song)) return false;
    if (isBusy.value) return true;
    final resume = loadedSongId.value == song.id && error.value == null;
    selectedSongId.value = song.id;
    _pauseRequested = false;
    _requestPlayback(resume: resume);
    return true;
  }

  void pauseSong(Song song) {
    if (_closed || isBusy.value || loadedSongId.value != song.id) return;
    _pauseRequested = true;
    _requestPlayback();
  }

  void _requestPlayback({bool resume = false, Duration? seek}) {
    _resumeRequested = resume;
    _seekPosition = seek;
    _revision++;
    error.value = null;
    // One worker owns the player. Inputs remain enabled while a load finishes.
    if (!isBusy.value) unawaited(_updatePlayback());
  }

  Future<void> _updatePlayback() async {
    isBusy.value = true;
    try {
      var appliedRevision = -1;
      while (!_closed && appliedRevision != _revision) {
        final revision = _revision;
        appliedRevision = revision;
        try {
          if (_pauseRequested) {
            await _player.pause();
            continue;
          }
          if (_resumeRequested &&
              playMusic.value &&
              loadedSongId.value == selectedSongId.value) {
            final seek = _seekPosition;
            if (seek != null) {
              isSeeking.value = true;
              await _player.seek(seek);
            }
            if (_closed || revision != _revision) continue;
            unawaited(_startPlayback(revision));
            continue;
          }
          await _player.stop();
          loadedSongId.value = null;
          if (_closed || revision != _revision) continue;
          final songId = selectedSongId.value;
          if (!playMusic.value || songId == null) continue;

          final song = localSongs.firstWhere((song) => song.id == songId);
          if (!canAccess(song)) continue;
          loadingSongId.value = song.id;
          await _player.setAsset(song.audioPath);
          if (_closed || revision != _revision) continue;
          loadedSongId.value = song.id;
          await _player.setLoopMode(LoopMode.one);
          if (_closed || revision != _revision) continue;
          // A looping play future only completes when playback stops.
          unawaited(_startPlayback(revision));
        } catch (_) {
          if (!_closed && revision == _revision) {
            error.value = 'Không thể tải hoặc phát nhạc. Vui lòng thử lại.';
          }
        }
      }
    } finally {
      if (!_closed) {
        loadingSongId.value = null;
        isSeeking.value = false;
        isBusy.value = false;
      }
    }
  }

  Future<void> _startPlayback(int revision) async {
    try {
      await _player.play();
    } catch (_) {
      if (!_closed && revision == _revision) {
        error.value = 'Không thể phát nhạc. Vui lòng thử lại.';
      }
    }
  }

  @override
  void onClose() {
    _closed = true;
    _revision++;
    unawaited(_errors?.cancel());
    unawaited(_states?.cancel());
    unawaited(_premiumChanges?.cancel());
    unawaited(_player.dispose());
    super.onClose();
  }
}
