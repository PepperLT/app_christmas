import 'package:christmas_countdown/app/christmas_app.dart';
import 'package:christmas_countdown/core/services/snowfall_service.dart';
import 'package:christmas_countdown/core/widget/app_menu_button.dart';
import 'package:christmas_countdown/core/widget/christmas_drawer.dart';
import 'package:christmas_countdown/core/widget/shareable_scaffold.dart';
import 'package:christmas_countdown/core/widget/snowfall_overlay.dart';
import 'package:christmas_countdown/features/about/presentation/page/about_page.dart';
import 'package:christmas_countdown/features/about/presentation/widgets/about_hero_card.dart';
import 'package:christmas_countdown/features/about/presentation/widgets/app_information_tile.dart';
import 'package:christmas_countdown/features/about/presentation/widgets/app_information_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Christmas Countdown',
      packageName: 'com.santa.christmascountdown',
      version: '2.7.4',
      buildNumber: '42',
      buildSignature: '',
    );
  });

  testWidgets('Version uses platform metadata and licenses entry is absent', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();
    expect(find.text('v2.7.4 (42)'), findsOneWidget);
    final versionTile = tester.widget<AppInformationTile>(
      find.widgetWithText(AppInformationTile, 'App Version'),
    );
    expect(versionTile.onTap, isNull);
    expect(find.text('Terms of Service'), findsNothing);
    expect(find.text('Contact & Support'), findsOneWidget);
    expect(find.text('Open Source Licenses'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final outcome in ['success', 'unavailable', 'exception']) {
    testWidgets('Contact launches configured email: $outcome', (tester) async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      String? launchedUrl;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            launchedUrl = (call.arguments as Map)['url'] as String;
            if (outcome == 'exception') {
              throw PlatformException(code: 'NO_EMAIL_APP');
            }
            return outcome == 'success';
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppInformationSection(supportEmail: 'thaivku@gmail.com'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final contact = find.text('Contact & Support');
      await tester.ensureVisible(contact);
      await tester.tap(contact);
      await tester.pumpAndSettle();
      final uri = Uri.parse(launchedUrl!);
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'thaivku@gmail.com');
      expect(uri.queryParameters['subject'], 'Christmas Countdown Support');
      expect(
        find.textContaining('Unable to open an email app.'),
        outcome == 'success' ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Small screens and large text scroll through all sections', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const AboutPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('App Features'), findsOneWidget);
      expect(find.text('App Information'), findsOneWidget);
      await tester.ensureVisible(
        find.text('Wishing you a peaceful and joyful Christmas.'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Hero grows to fit enlarged text without clipping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();
    final standardHeight = tester.getSize(find.byType(AboutHeroCard)).height;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const AboutPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AboutHeroCard)).height,
      greaterThan(standardHeight),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('About retains shared scaffold, menu and Share entry', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();
    expect(find.byType(ShareableScaffold), findsOneWidget);
    expect(find.byType(AppMenuButton), findsOneWidget);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    expect(find.byType(ChristmasDrawer), findsOneWidget);
    final share = find.widgetWithText(ListTile, 'Share');
    expect(tester.widget<ListTile>(share).onTap, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Snowfall remains above About and ignores pointer input', (
    tester,
  ) async {
    Get.put(SnowfallService(), permanent: true);
    addTearDown(Get.reset);
    await tester.pumpWidget(const ChristmasApp());
    await tester.pump(const Duration(milliseconds: 500));
    Get.offNamed('/about');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.byType(SnowfallOverlay), findsOneWidget);
    final snow = find.descendant(
      of: find.byType(SnowfallOverlay),
      matching: find.byType(IgnorePointer),
    );
    expect(tester.widget<IgnorePointer>(snow).ignoring, isTrue);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ChristmasDrawer), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
