import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotShareService {
  ScreenshotShareService({Future<void> Function(ShareParams)? share})
    : _share = share ?? _shareWithPlatform;

  final Future<void> Function(ShareParams) _share;

  static Future<void> _shareWithPlatform(ShareParams params) async {
    await SharePlus.instance.share(params);
  }

  Future<void> shareCountdown(RenderRepaintBoundary boundary) async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not encode screenshot');
      await _share(
        ShareParams(
          title: 'Christmas Countdown',
          files: [
            XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png'),
          ],
          fileNameOverrides: ['christmas_countdown.png'],
          sharePositionOrigin:
              boundary.localToGlobal(Offset.zero) & boundary.size,
        ),
      );
    } finally {
      image.dispose();
    }
  }
}
