import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_countdown/core/services/screenshot_share_service.dart';
import 'package:christmas_countdown/core/widget/christmas_drawer.dart';
import 'package:christmas_countdown/core/widget/shareable_scaffold.dart';

void main() {
  testWidgets('Shared page enables Share, closes drawer and sends a PNG once', (
    tester,
  ) async {
    var calls = 0;
    final service = ScreenshotShareService(
      share: (params) async {
        calls++;
        expect(
          find.byType(ChristmasDrawer),
          findsNothing,
          reason:
              'Capture must wait for drawer animation and scrim to disappear',
        );
        expect(
          tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
          isFalse,
        );
        expect(params.files, hasLength(1));
        final bytes = await params.files!.single.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 1600);
        expect(frame.image.height, 1200);
        frame.image.dispose();
        codec.dispose();
        expect(bytes.take(4), [137, 80, 78, 71]);
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ShareableScaffold(
          shareService: service,
          drawer: const ChristmasDrawer(
            activeItem: ChristmasMenuItem.bubbleBox,
            routes: {},
          ),
          appBar: AppBar(title: const Text('Page')),
          body: const Center(child: Text('Content to share')),
          bottomNavigationBar: const SizedBox(
            height: 50,
            child: Text('Footer'),
          ),
        ),
      ),
    );
    final capture = find
        .ancestor(
          of: find.byType(Scaffold),
          matching: find.byType(RepaintBoundary),
        )
        .evaluate()
        .first;
    expect(
      find.descendant(
        of: find.byWidget(capture.widget),
        matching: find.byType(ChristmasDrawer),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byWidget(capture.widget),
        matching: find.byType(AppBar),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byWidget(capture.widget),
        matching: find.text('Content to share'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byWidget(capture.widget),
        matching: find.text('Footer'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Share'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (var i = 0; calls == 0 && i < 50; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
