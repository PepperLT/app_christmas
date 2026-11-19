import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/song.dart';
import '../../domain/song_repository.dart';
import '../../domain/music_player.dart';

/// App-wide music state. Infrastructure is injected through domain contracts.
/// The compatibility service preserves the existing GetX lifecycle ownership.
class MusicController extends GetxService {
  MusicController({
    required MusicPlayer player,
    required bool Function(Song) canAccess,
    Stream<bool> Function()? accessChanges,
    SongRepository? repository,
    List<Song> initialSongs = const [],
    this.playlistTimeout = const Duration(seconds: 15),
    this.audioTimeout = const Duration(seconds: 20),
  }) : _player = player,
       _canAccess = canAccess,
       _accessChanges = accessChanges,
       _repository = repository,
       songs = initialSongs.toList().obs;

  final SongRepository? _repository;
  final Duration playlistTimeout;
  final Duration audioTimeout;
  final bool Function(Song) _canAccess;
  final Stream<bool> Function()? _accessChanges;
  final RxList<Song> songs;
  final isLoadingSongs = false.obs;
  final songsError = RxnString();

  Future<void>? _catalogRequest;
  int _catalogGeneration = 0;

  Future<void> loadSongs() {
    if (_closed || _repository == null) return Future.value();
    if (_catalogRequest != null) return _catalogRequest!;
    final generation = ++_catalogGeneration;
    return _catalogRequest = _loadSongs(generation).whenComplete(() {
      if (generation == _catalogGeneration) _catalogRequest = null;
    });
  }

  Future<void> _loadSongs(int generation) async {
    isLoadingSongs.value = true;
    songsError.value = null;
    try {
      final result = await _repository!.fetchSongs().timeout(playlistTimeout);
      if (_closed || generation != _catalogGeneration) return;
      final previous = selectedSong;
      songs.assignAll(result);
      if (selectedSongId.value != null &&
          !songs.any((song) => song.id == selectedSongId.value)) {
        selectedSongId.value = null;
        _requestPlayback();
      } else if (previous != null &&
          selectedSong?.audioPath != previous.audioPath) {
        _requestPlayback();
      }
    } catch (_) {
      if (!_closed && generation == _catalogGeneration) {
        songsError.value =
            'The playlist could not be loaded. Please try again.';
      }
    } finally {
      if (!_closed && generation == _catalogGeneration) {
        isLoadingSongs.value = false;
      }
    }
  }

  final MusicPlayer _player;
  final playMusic = false.obs;
  final selectedSongId = RxnString();
  final isBusy = false.obs;
  final isSeeking = false.obs;
  final error = RxnString();
  final isPlaying = false.obs;
  final loadedSongId = RxnString();
  final loadingSongId = RxnString();
  String? _loadedAudioSource;
  Song? get selectedSong =>
      songs.firstWhereOrNull((song) => song.id == selectedSongId.value);
  bool _pauseRequested = false;
  bool _resumeRequested = false;
  Duration? _seekPosition;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool canAccess(Song song) => _canAccess(song);

  /// Finds the next accessible song, wrapping at the end of the catalog.
  /// Returns null if the current song is missing or no other song is accessible.
  Song? nextSongOf(Song currentSong) => _adjacentSongOf(currentSong, 1);

  /// Finds the previous accessible song, wrapping at the start of the catalog.
  /// Returns null if the current song is missing or no other song is accessible.
  Song? previousSongOf(Song currentSong) => _adjacentSongOf(currentSong, -1);

  Song? _adjacentSongOf(Song currentSong, int direction) {
    final currentIndex = songs.indexWhere((song) => song.id == currentSong.id);
    if (currentIndex < 0) return null;

    for (var offset = 1; offset < songs.length; offset++) {
      final index = (currentIndex + direction * offset) % songs.length;
      final candidate = songs[index];
      if (candidate.id != currentSong.id && canAccess(candidate)) {
        return candidate;
      }
    }
    return null;
  }

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
  StreamSubscription<Object>? _errors;
  StreamSubscription<bool>? _states;
  StreamSubscription<bool>? _premiumChanges;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadSongs());
    _premiumChanges = _accessChanges?.call().listen((_) {
      final selected = songs.where((song) => song.id == selectedSongId.value);
      if (!_closed && selected.isNotEmpty && !canAccess(selected.first)) {
        selectedSongId.value = null;
        _requestPlayback();
      }
    });
    _errors = _player.errorStream.listen((exception) {
      if (!_closed && playMusic.value && selectedSongId.value != null) {
        error.value = 'Music cannot be played. Please try again.';
      }
    });
    _states = _player.playingStream.listen((playing) {
      if (!_closed) isPlaying.value = playing;
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

  bool _retrying = false;

  Future<void> retry() async {
    if (_closed || _retrying) return;
    final revision = _revision;
    final songId = selectedSongId.value;
    _retrying = true;
    try {
      if (_repository != null) {
        await loadSongs();
        if (songsError.value != null) return;
      }
      // Do not restart an old selection after a switch, pause or disposal.
      if (_closed || revision != _revision || selectedSongId.value != songId) {
        return;
      }
      _pauseRequested = false;
      _requestPlayback();
    } finally {
      _retrying = false;
    }
  }

  // Returns false when the app-wide music switch is off.
  bool playSong(Song song) {
    final latest = songs.where((item) => item.id == song.id);
    if (latest.isNotEmpty) song = latest.first;
    if (_closed || !playMusic.value || !canAccess(song)) return false;
    if (isBusy.value || isLoadingSongs.value) return true;
    if (songsError.value != null) {
      selectedSongId.value = song.id;
      unawaited(retry());
      return true;
    }
    if (error.value != null && selectedSongId.value == song.id) {
      unawaited(retry());
      return true;
    }
    final resume =
        loadedSongId.value == song.id &&
        _loadedAudioSource == song.audioPath &&
        error.value == null;
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
          if (_pauseRequested &&
              _loadedAudioSource == selectedSong?.audioPath) {
            await _player.pause().timeout(audioTimeout);
            continue;
          }
          if (_resumeRequested &&
              playMusic.value &&
              loadedSongId.value == selectedSongId.value &&
              _loadedAudioSource == selectedSong?.audioPath) {
            final seek = _seekPosition;
            if (seek != null) {
              isSeeking.value = true;
              await _player.seek(seek).timeout(audioTimeout);
            }
            if (_closed || revision != _revision) continue;
            unawaited(_startPlayback(revision));
            continue;
          }
          await _player.stop().timeout(audioTimeout);
          if (_closed) return;
          loadedSongId.value = null;
          _loadedAudioSource = null;
          if (_closed || revision != _revision) continue;
          final songId = selectedSongId.value;
          if (!playMusic.value || songId == null || _pauseRequested) continue;

          final song = songs.firstWhere((song) => song.id == songId);
          if (!canAccess(song)) continue;
          loadingSongId.value = song.id;
          await _player.load(song.audioPath).timeout(audioTimeout);
          if (_closed || revision != _revision) continue;
          loadedSongId.value = song.id;
          _loadedAudioSource = song.audioPath;
          await _player.loopCurrentSong().timeout(audioTimeout);
          if (_closed || revision != _revision) continue;
          // A looping play future only completes when playback stops.
          unawaited(_startPlayback(revision));
        } on TimeoutException {
          if (_closed) return;
          loadedSongId.value = null;
          _loadedAudioSource = null;
          isPlaying.value = false;
          // Reset isolates late native operations on a retired player. A timeout
          // alone would leave the same native instance free to overwrite a retry.
          try {
            await _player.reset().timeout(audioTimeout);
          } catch (_) {
            // The next operation can attempt recovery again; always clear busy.
          }
          if (!_closed && revision == _revision) {
            error.value = 'Music loading timed out. Please try again.';
          }
        } catch (_) {
          if (!_closed && revision == _revision) {
            error.value = 'Unable to load or play music. Please try again.';
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
    _catalogGeneration++;
    unawaited(_errors?.cancel());
    unawaited(_states?.cancel());
    unawaited(_premiumChanges?.cancel());
    unawaited(_player.dispose());
    super.onClose();
  }
}
