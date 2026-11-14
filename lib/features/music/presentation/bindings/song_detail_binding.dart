import 'package:get/get.dart';

import '../../music_dependencies.dart';
import '../../domain/entities/song.dart';
import '../controllers/song_detail_controller.dart';

class SongDetailBinding extends Bindings {
  SongDetailBinding(this.song);

  final Song song;

  @override
  void dependencies() {
    Get.lazyPut<SongDetailController>(
      () => SongDetailController(song: song, service: findMusicController()),
      tag: song.id,
    );
  }
}
