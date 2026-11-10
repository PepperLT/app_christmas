import 'package:christmas_countdown/core/widget/app_menu_button.dart';
import 'package:christmas_countdown/core/widget/christmas_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local_songs.dart';
import '../../data/music_player_service.dart';
import '../bindings/song_detail_binding.dart';
import 'song_detail_page.dart';

class MusicPage extends GetView<MusicPlayerService> {
  const MusicPage({super.key, required this.menuRoutes});

  final Map<ChristmasMenuItem, String> menuRoutes;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFE4DF);
    const accentColor = Color(0xFFB4232B);
    const selectedColor = Color(0xFF4D992C);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: ChristmasDrawer(
        activeItem: ChristmasMenuItem.music,
        routes: menuRoutes,
      ),
      drawerScrimColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        leadingWidth: 64,
        leading: Builder(
          builder: (drawerContext) => Center(
            child: AppMenuButton(
              onPressed: () => Scaffold.of(drawerContext).openDrawer(),
            ),
          ),
        ),
        title: const Text(
          'Santa Songs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final error = controller.error.value;
          final selectedSongId = controller.selectedSongId.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF0DFDC)),
                ),
                child: SwitchListTile(
                  secondary: const Icon(
                    Icons.music_note_rounded,
                    color: accentColor,
                  ),
                  title: const Text(
                    'Play Music',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: controller.playMusic.value,
                  activeTrackColor: selectedColor,
                  onChanged: controller.setPlayMusic,
                ),
              ),
              if (controller.isBusy.value) const LinearProgressIndicator(),
              if (error != null)
                ListTile(
                  title: Text(error),
                  trailing: TextButton(
                    onPressed: controller.retry,
                    child: const Text('Thử lại'),
                  ),
                ),
              const SizedBox(height: 28),
              for (final song in localSongs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    minTileHeight: 112,
                    horizontalTitleGap: 16,
                    tileColor: const Color(0xFFFFF6F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFF3B5AC)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    onTap: () => Get.to(
                      () => SongDetailPage(song: song),
                      binding: SongDetailBinding(song),
                    ),
                    title: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6AAA0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEA9186)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(
                              song.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: Color(0xFFFFE3DF),
                                child: Center(
                                  child: Icon(
                                    Icons.music_note,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            song.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              color: Color(0xFF70343B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      iconSize: 32,
                      tooltip: selectedSongId == song.id
                          ? 'Bỏ chọn ${song.title}'
                          : 'Chọn ${song.title}',
                      icon: selectedSongId == song.id
                          ? const Icon(Icons.check_circle, color: selectedColor)
                          : const Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                            ),
                      onPressed: () => controller.toggleSong(song),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
