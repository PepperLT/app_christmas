import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:christmas_countdown/features/wallpapers/data/wallpaper_service.dart';
import 'package:christmas_countdown/features/wallpapers/presentation/controllers/wallpapers_controller.dart';
import 'package:christmas_countdown/features/wallpapers/presentation/page/wallpapers_page.dart';

void main() {
  test(
    'Wallpaper persists, restores default and rejects unknown assets',
    () async {
      SharedPreferences.setMockInitialValues({
        'countdown_wallpaper': 'missing.png',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = WallpaperService(preferences: prefs);
      expect(service.selectedAsset.value, WallpaperService.defaultAsset);
      await service.select(WallpaperService.assets[1]);
      expect(
        WallpaperService(preferences: prefs).selectedAsset.value,
        WallpaperService.assets[1],
      );
      await expectLater(service.select('invalid'), throwsArgumentError);
      await service.select(WallpaperService.defaultAsset);
      expect(
        WallpaperService(preferences: prefs).selectedAsset.value,
        WallpaperService.defaultAsset,
      );
    },
  );
  testWidgets('Preview applies wallpaper with no overflow on small landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(Get.reset);
    final service = WallpaperService();
    Get.put(WallpapersController(service: service));
    await tester.pumpWidget(const GetMaterialApp(home: WallpapersPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Giáng sinh 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giáng sinh 1'));
    await tester.pumpAndSettle();
    expect(find.text('Dùng cho Countdown'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Dùng cho Countdown'));
    await tester.pumpAndSettle();
    expect(service.selectedAsset.value, WallpaperService.assets[1]);
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
