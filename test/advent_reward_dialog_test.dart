import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_countdown/features/advent_calendar/domain/entity/advent_day.dart';
import 'package:christmas_countdown/features/advent_calendar/presentation/widgets/advent_reward_dialog.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(667, 375)]) {
    testWidgets('Reward dialog fits $size and can close', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => const AdventRewardDialog(
                        day: AdventDay(
                          day: 1,
                          title: 'Chào tháng 12!',
                          message: 'Hãy trang trí góc yêu thích của bạn.',
                        ),
                        isNewlyClaimed: true,
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Tuyệt vời!'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tuyệt vời!'));
      await tester.pumpAndSettle();
      expect(find.byType(AdventRewardDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
