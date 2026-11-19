import 'package:christmas_countdown/features/about/presentation/page/about_page.dart';
import 'package:christmas_countdown/features/about/presentation/page/privacy_policy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:christmas_countdown/features/about/presentation/privacy_policy_document.dart';
import 'package:christmas_countdown/features/about/presentation/widgets/privacy_policy_components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('About opens the bundled policy and returns without network', (
    tester,
  ) async {
    final source = (await tester.runAsync(
      () => rootBundle.loadString('docs/legal/privacy_policy.md'),
    ))!;
    final document = PrivacyPolicyDocument.parse(source);
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();
    final policy = find.text('Privacy Policy');
    expect(policy, findsOneWidget);
    await tester.ensureVisible(policy);
    await tester.pumpAndSettle();
    await tester.tap(policy);
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(find.text(document.sections.first.title), findsOneWidget);
    final storage = find.text(document.sections[2].title);
    await tester.ensureVisible(storage);
    await tester.tap(storage);
    await tester.pumpAndSettle();
    final details = find.descendant(
      of: find.byType(PolicySectionTile).at(2),
      matching: find.byType(PolicyMarkdown),
    );
    expect(details, findsOneWidget);
    expect(
      tester.widget<PolicyMarkdown>(details).data,
      startsWith(document.sections[2].markdown),
    );
    final contact = find.text('Email: ${document.email}');
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
