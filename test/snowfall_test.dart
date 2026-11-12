import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:christmas_countdown/core/services/snowfall_service.dart';
import 'package:christmas_countdown/core/widget/snowfall_overlay.dart';

void main() {
  test('Snowfall defaults on and persists enabled state', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = SnowfallService(preferences: preferences);
    expect(service.enabled.value, isTrue);
    await service.setEnabled(false);
    expect(service.enabled.value, isFalse);
    expect(SnowfallService(preferences: preferences).enabled.value, isFalse);
    await service.setEnabled(true);
    expect(preferences.getBool('snowfall_enabled'), isTrue);
  });

  testWidgets('Snow animates at different sizes without blocking taps', (
    tester,
  ) async {
    var taps = 0;
    for (final size in [const Size(320, 568), const Size(844, 390)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: TextButton(
                  onPressed: () => taps++,
                  child: const Text('Tap'),
                ),
              ),
              const SnowfallOverlay(),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Tap'));
      expect(tester.takeException(), isNull);
    }
    expect(taps, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
