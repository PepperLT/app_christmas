import 'package:christmas_countdown/core/services/screenshot_share_service.dart';
import 'package:christmas_countdown/core/widget/app_menu_button.dart';
import 'package:christmas_countdown/core/widget/christmas_drawer.dart';
import 'package:christmas_countdown/features/countdown/presentation/controllers/countdown_controller.dart';
import 'package:christmas_countdown/features/countdown/presentation/pages/countdown_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  testWidgets('One Share tap registers request before drawer close callback', (
    tester,
  ) async {
    final events = <String>[];
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          onDrawerChanged: (opened) {
            if (!opened) events.add('closed');
          },
          drawer: ChristmasDrawer(
            activeItem: ChristmasMenuItem.countdown,
            routes: const {},
            onShare: () => events.add('share'),
          ),
        ),
      ),
    );
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Share'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(events, ['share', 'closed']);
    expect(scaffoldKey.currentState!.isDrawerOpen, isFalse);
  });

  testWidgets('Countdown capture produces PNG and excludes the menu', (
    tester,
  ) async {
    Get.testMode = true;
    final controller = Get.put(CountdownController());
    addTearDown(() {
      controller.onClose();
      Get.reset();
    });
    await tester.pumpWidget(const GetMaterialApp(home: CountdownPage()));
    await tester.pumpAndSettle();
    final capture = find.byKey(controller.screenshotKey);
    expect(
      find.descendant(of: capture, matching: find.byType(AppMenuButton)),
      findsNothing,
    );
    expect(find.byType(AppMenuButton), findsOneWidget);
    expect(
      find.descendant(of: capture, matching: find.text('Seconds')),
      findsOneWidget,
    );
    ShareParams? shared;
    final service = ScreenshotShareService(
      share: (params) async {
        shared = params;
      },
    );
    final boundary = tester.renderObject<RenderRepaintBoundary>(capture);
    await tester.runAsync(() => service.shareCountdown(boundary));
    expect(shared, isNotNull);
    expect(shared!.files!.single.mimeType, 'image/png');
    final bytes = await shared!.files!.single.readAsBytes();
    expect(bytes.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
    expect(shared!.sharePositionOrigin!.width, greaterThan(0));
    controller.onClose();
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });
}
