import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/screenshot_share_service.dart';
import 'christmas_drawer.dart';

/// Captures the current page only after the drawer finishes closing.
class ShareableScaffold extends StatefulWidget {
  const ShareableScaffold({
    super.key,
    required this.drawer,
    this.appBar,
    this.body,
    this.backgroundColor,
    this.drawerScrimColor,
    this.bottomNavigationBar,
    this.shareService,
  });

  final ChristmasDrawer drawer;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Color? backgroundColor;
  final Color? drawerScrimColor;
  final Widget? bottomNavigationBar;
  final ScreenshotShareService? shareService;

  @override
  State<ShareableScaffold> createState() => _ShareableScaffoldState();
}

class _ShareableScaffoldState extends State<ShareableScaffold> {
  final _captureKey = GlobalKey();
  bool _pending = false;
  bool _sharing = false;

  void _requestShare() {
    if (!_sharing) _pending = true;
  }

  Future<void> _drawerChanged(bool opened) async {
    if (opened || !_pending || _sharing) return;
    _pending = false;
    _sharing = true;
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary = _captureKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary || !boundary.attached) {
        throw StateError('Page is not visible');
      }
      await (widget.shareService ?? ScreenshotShareService()).shareCountdown(
        boundary,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể chia sẻ ảnh. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      _sharing = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.appBar,
    body: RepaintBoundary(
      key: _captureKey,
      child: ColoredBox(
        color:
            widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox.expand(child: widget.body),
      ),
    ),
    backgroundColor: widget.backgroundColor,
    drawerScrimColor: widget.drawerScrimColor,
    bottomNavigationBar: widget.bottomNavigationBar,
    onDrawerChanged: _drawerChanged,
    drawer: ChristmasDrawer(
      activeItem: widget.drawer.activeItem,
      routes: widget.drawer.routes,
      onShare: _requestShare,
    ),
  );
}
