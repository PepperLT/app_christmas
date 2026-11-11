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
          tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
          isFalse,
        );
        expect(params.files, hasLength(1));
        expect((await params.files!.single.readAsBytes()).take(4), [
          137,
          80,
          78,
          71,
        ]);
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
        ),
      ),
    );
    final capture = find
        .ancestor(
          of: find.text('Content to share'),
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
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byWidget(capture.widget),
        matching: find.text('Content to share'),
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
