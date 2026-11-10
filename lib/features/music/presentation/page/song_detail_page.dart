import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/song_detail_controller.dart';
import '../widgets/song_progress.dart';
import '../../domain/entities/song.dart';

class SongDetailPage extends GetView<SongDetailController> {
  const SongDetailPage({super.key, required this.song});

  final Song song;

  @override
  String get tag => song.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE4DF),
        foregroundColor: const Color(0xFF70343B),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6AAA0),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFEA9186)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2470343B),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          song.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: Color(0xFFFFE3DF),
                            child: Icon(
                              Icons.music_note,
                              size: 96,
                              color: Color(0xFFB4232B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() {
                    final busy = controller.isBusy;
                    final playing = controller.isPlaying;
                    final loadingThisSong = controller.isLoadingSong;
                    final error = controller.error;
                    return Column(
                      children: [
                        SongProgress(
                          position: controller.visiblePosition,
                          duration: controller.visibleDuration,
                          enabled: controller.canSeek,
                          onSeek: controller.seekTo,
                        ),
                        if (busy) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            loadingThisSong
                                ? 'Đang tải ${song.title}…'
                                : 'Đang xử lý…',
                          ),
                          const SizedBox(height: 12),
                        ],
                        IconButton.filled(
                          tooltip: playing ? 'Pause' : 'Play',
                          iconSize: 42,
                          style: IconButton.styleFrom(
                            fixedSize: const Size(80, 80),
                            shape: const CircleBorder(),
                            backgroundColor: const Color(0xFFB4232B),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFE3ADA6),
                            disabledForegroundColor: Colors.white70,
                          ),
                          onPressed: busy
                              ? null
                              : () {
                                  if (!controller.togglePlayback()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Hãy bật Play Music ở Santa Songs để phát nhạc.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 16),
                          Text(error, textAlign: TextAlign.center),
                          const Text('Nhấn Play để thử lại.'),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
