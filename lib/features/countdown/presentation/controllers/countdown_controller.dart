import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/services/screenshot_share_service.dart';

class CountdownController extends GetxController {
  final screenshotKey = GlobalKey();
  final isSharing = false.obs;
  final shareError = RxnString();
  final _shareService = ScreenshotShareService();
  bool _sharePending = false;

  void requestShare() {
    if (isSharing.value || isClosed) return;
    _sharePending = true;
  }

  Future<void> onDrawerChanged(bool opened) async {
    if (opened || !_sharePending || isSharing.value || isClosed) return;
    _sharePending = false;
    isSharing.value = true;
    shareError.value = null;
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (isClosed) return;
      final boundary = screenshotKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary || !boundary.attached) {
        throw StateError('Countdown is not visible');
      }
      await _shareService.shareCountdown(boundary);
    } catch (_) {
      if (!isClosed) {
        shareError.value = 'Không thể chia sẻ ảnh. Vui lòng thử lại.';
      }
    } finally {
      if (!isClosed) isSharing.value = false;
    }
  }

  final remaining = Duration.zero.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _updateCountdown();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final christmas = DateTime(now.year, 12, 25);
    final dayAfterChristmas = DateTime(now.year, 12, 26);

    if (!now.isBefore(christmas) && now.isBefore(dayAfterChristmas)) {
      remaining.value = Duration.zero;
      return;
    }

    final target = now.isBefore(christmas)
        ? christmas
        : DateTime(now.year + 1, 12, 25);

    remaining.value = target.difference(now);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
