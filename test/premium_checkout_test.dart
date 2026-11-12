import 'package:christmas_countdown/features/premium/presentation/widgets/premium_components.dart';
import 'package:get/get.dart';
import 'package:christmas_countdown/features/music/data/music_player_service.dart';
import 'package:christmas_countdown/features/music/data/local_songs.dart';
import 'package:christmas_countdown/features/music/presentation/page/music_page.dart';
import 'package:christmas_countdown/features/premium/data/premium_service.dart';
import 'package:christmas_countdown/features/premium/domain/premium_plan.dart';
import 'package:christmas_countdown/features/premium/presentation/widgets/premium_dialog.dart';
import 'music_player_service_test.dart' show FakePlayer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_countdown/features/premium/presentation/page/premium_page.dart';
import 'package:christmas_countdown/features/premium/presentation/widgets/premium_checkout_dialog.dart';

class _Assets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/images/header.png') {
      return ByteData.sublistView(File(key).readAsBytesSync());
    }
    return rootBundle.load(key);
  }
}

void main() {
  tearDown(() => Get.reset());
  testWidgets('Checkout reflects selected plan and can return to change it', (
    tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _Assets(),
        child: const MaterialApp(home: PremiumPage()),
      ),
    );
    await tester.pumpAndSettle();
    final next = find.text('Tiếp tục thanh toán');
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('\$33 / năm'), findsOneWidget);
    expect(
      tester
          .widget<PremiumActionButton>(
            find.widgetWithText(
              PremiumActionButton,
              'Thanh toán — chưa khả dụng',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Quay lại'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Hàng tháng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hàng tháng'));
    await tester.pump();
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('\$3 / tháng'), findsOneWidget);
    expect(find.byType(PremiumCheckoutDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Locked music and Premium page share plan selection and checkout',
    (tester) async {
      Get.testMode = true;
      final player = FakePlayer();
      Get.put(MusicPlayerService(player: player));
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _Assets(),
          child: const MaterialApp(home: MusicPage(menuRoutes: {})),
        ),
      );
      await tester.pumpAndSettle();
      final title = localSongs.firstWhere((song) => song.isPremium).title;
      await tester.scrollUntilVisible(
        find.text(title),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byType(PremiumDialog), findsOneWidget);
      await tester.ensureVisible(find.text('Hàng tháng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hàng tháng'));
      await tester.pump();
      expect(PremiumService.instance.selectedPlan.value, PremiumPlan.monthly);
      await tester.ensureVisible(find.text('Tiếp tục thanh toán'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiếp tục thanh toán'));
      await tester.pumpAndSettle();
      expect(find.text('\$3 / tháng'), findsOneWidget);
      expect(player.loads, 0);
      await tester.tap(find.text('Quay lại'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _Assets(),
          child: const MaterialApp(home: PremiumPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tiếp tục thanh toán'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiếp tục thanh toán'));
      await tester.pumpAndSettle();
      expect(find.text('\$3 / tháng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
