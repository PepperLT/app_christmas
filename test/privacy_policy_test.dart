import 'package:christmas_countdown/features/about/presentation/page/about_page.dart';
import 'package:christmas_countdown/features/about/presentation/page/privacy_policy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('About opens the bundled policy and returns without network', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();
    final policy = find.text('Privacy Policy');
    expect(policy, findsOneWidget);
    await tester.ensureVisible(policy);
    await tester.pumpAndSettle();
    await tester.tap(policy);
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(find.text('1. About this policy'), findsOneWidget);
    expect(
      find.textContaining('does not persist the music switch'),
      findsOneWidget,
    );
    final contact = find.text('Email: thaivku@gmail.com');
    await tester.ensureVisible(contact);
    await tester.pumpAndSettle();
    expect(contact.hitTestable(), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsNothing);
    expect(find.byType(AboutPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
