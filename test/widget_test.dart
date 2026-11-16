import 'package:christmas_countdown/app/christmas_app.dart';
import 'package:christmas_countdown/features/welcome/presentation/pages/welcome_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets('App displays welcome page', (WidgetTester tester) async {
    await tester.pumpWidget(const ChristmasApp());
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.text('Christmas\nCountdown'), findsOneWidget);
  });
}
