/// Connects the music controller to audio, Premium and the existing app API.
library;

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../premium/data/premium_service.dart';
import 'data/just_audio_music_player.dart';
import 'domain/entities/song.dart';
import 'domain/song_repository.dart';
import 'presentation/controllers/music_controller.dart';

/// Keeps the shared registration used by main.dart and Settings unchanged.
class MusicPlayerService extends MusicController {
  MusicPlayerService({
    AudioPlayer? player,
    Future<List<Song>> Function()? fetchSongs,
    super.initialSongs,
  }) : super(
         player: JustAudioMusicPlayer(player: player),
         canAccess: (song) => !song.isPremium || PremiumService.isUnlocked,
         accessChanges: () => Get.isRegistered<PremiumService>()
             ? Get.find<PremiumService>().accessChanges
             : const Stream<bool>.empty(),
         repository: fetchSongs == null ? null : _SongLoader(fetchSongs),
       );
}

/// The page resolves the same shared instance as Settings; no second player.
MusicController findMusicController() => Get.find<MusicPlayerService>();

/// Adapts the loader already injected by main.dart and existing tests.
class _SongLoader implements SongRepository {
  const _SongLoader(this._fetch);
  final Future<List<Song>> Function() _fetch;

  @override
  Future<List<Song>> fetchSongs() => _fetch();
}
