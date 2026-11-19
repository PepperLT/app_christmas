import 'package:christmas_countdown/features/about/presentation/page/privacy_policy_page.dart';
import 'package:christmas_countdown/features/about/presentation/privacy_policy_document.dart';
import 'package:christmas_countdown/features/about/presentation/widgets/privacy_policy_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

class PolicyTestBundle extends CachingAssetBundle {
  PolicyTestBundle(this.source, {this.fail = false});
  final String source;
  bool fail;
  final requests = <String>[];

  @override
  Future<ByteData> load(String key) => rootBundle.load(key);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    requests.add(key);
    if (fail) throw FlutterError('Asset unavailable');
    return source;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Parser retains all ten bodies, metadata and the unchanged source',
    () async {
      final source = await rootBundle.loadString(
        'docs/legal/privacy_policy.md',
      );
      final doc = PrivacyPolicyDocument.parse(source);
      expect(doc.source, source);
      expect(doc.sections, hasLength(10));
      expect(doc.metadata('Last updated'), 'November 19, 2026');
      expect(doc.metadata('Android package'), 'com.santa.christmascountdown');
      expect(doc.isDraft, isFalse);
      expect(doc.email, 'thaivku@gmail.com');
      final reconstructed = [
        doc.introduction,
        ...doc.sections.map((s) => '## ${s.title}\n${s.markdown}'),
      ].join('\n');
      expect(reconstructed, source.replaceAll('\r\n', '\n'));
    },
  );

  test(
    'Parser ignores headings in fences and preserves unsupported structure',
    () {
      const source =
          '# Policy\n\nIntro\n\n## One\n\n```md\n## Not a section\n```\n\n### Subheading\n**Bold** and [link][provider].\n\n## Two\nText\n\n[provider]: https://example.com\n';
      final doc = PrivacyPolicyDocument.parse(source);
      expect(doc.sections, hasLength(2));
      expect(doc.sections.first.markdown, contains('## Not a section'));
      expect(doc.sections.first.markdown, contains('### Subheading'));
      expect(doc.linkDefinitions, contains('[provider]: https://example.com'));
      const changed =
          '# Policy\n\nNo level-two headings.\n\n- Keep this list.\n';
      final fallback = PrivacyPolicyDocument.parse(changed);
      expect(fallback.sections, isEmpty);
      expect(fallback.introduction, changed);
    },
  );

  testWidgets(
    'All ten sections start collapsed and each expands and collapses',
    (tester) async {
      final source = (await tester.runAsync(
        () => rootBundle.loadString('docs/legal/privacy_policy.md'),
      ))!;
      final doc = PrivacyPolicyDocument.parse(source);
      final bundle = PolicyTestBundle(source);
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: bundle,
          child: const MaterialApp(home: PrivacyPolicyPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ExpansionTile), findsNWidgets(10));
      expect(find.text('Draft'), findsNothing);
      expect(find.textContaining('Last updated:'), findsNothing);
      expect(find.text('Android package'), findsNothing);
      expect(find.text('com.santa.christmascountdown'), findsNothing);
      expect(
        find.textContaining(
          'This document has not yet been published',
          findRichText: true,
        ),
        findsNothing,
      );
      for (var i = 0; i < 10; i++) {
        final tile = find.byType(PolicySectionTile).at(i);
        final detail = find.descendant(
          of: tile,
          matching: find.byType(PolicyMarkdown),
        );
        expect(detail, findsNothing);
        final title = find.text(doc.sections[i].title);
        await tester.ensureVisible(title);
        await tester.pumpAndSettle();
        await tester.tap(title);
        await tester.pumpAndSettle();
        expect(detail, findsOneWidget);
        expect(
          tester.widget<PolicyMarkdown>(detail).data,
          startsWith(doc.sections[i].markdown),
        );
        await tester.ensureVisible(title);
        await tester.pumpAndSettle();
        await tester.tap(title);
        await tester.pumpAndSettle();
        expect(detail, findsNothing);
      }
      expect(bundle.requests.toSet(), {'docs/legal/privacy_policy.md'});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Asset failures offer retry and recovery without internet', (
    tester,
  ) async {
    final bundle = PolicyTestBundle(
      '# Privacy Policy\n\n## Test\nRecovered policy.',
      fail: true,
    );
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: const MaterialApp(home: PrivacyPolicyPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    bundle.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.text('Draft'), findsNothing);
    expect(find.byType(PolicyContactCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Changed document without section headings displays all Markdown', (
    tester,
  ) async {
    const source =
        '# Updated policy\n\n**Important**\n\n- First item\n- Second item\n\n[Provider](https://example.com)';
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: PolicyTestBundle(source),
        child: const MaterialApp(home: PrivacyPolicyPage()),
      ),
    );
    await tester.pumpAndSettle();
    final renderer = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(renderer.data, startsWith(source));
    expect(find.text('First item', findRichText: true), findsOneWidget);
    expect(find.text('Second item', findRichText: true), findsOneWidget);
    final bold = tester.widget<RichText>(
      find.text('Important', findRichText: true),
    );
    expect(
      (bold.text as TextSpan).children!.first.style?.fontWeight,
      FontWeight.w700,
    );
    expect(tester.takeException(), isNull);
  });

  for (final outcome in ['success', 'unavailable', 'exception']) {
    testWidgets('Provider and contact links use launcher: $outcome', (
      tester,
    ) async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final urls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        urls.add((call.arguments as Map)['url'] as String);
        if (outcome == 'exception') {
          throw PlatformException(code: 'UNAVAILABLE');
        }
        return outcome == 'success';
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));
      await tester.pumpAndSettle();
      final providerSection = find.text(
        '4. Network requests and service providers',
      );
      await tester.ensureVisible(providerSection);
      await tester.tap(providerSection);
      await tester.pumpAndSettle();
      final providerLink = find.textContaining(
        'https://policies.google.com/privacy',
        findRichText: true,
      );
      await tester.ensureVisible(providerLink);
      await tester.pumpAndSettle();
      await tester.tapOnText(
        find.textRange.ofSubstring('https://policies.google.com/privacy'),
      );
      await tester.pumpAndSettle();
      expect(urls, ['https://policies.google.com/privacy']);
      final email = find.text('Email: thaivku@gmail.com');
      await tester.ensureVisible(email);
      await tester.pumpAndSettle();
      await tester.tap(email);
      await tester.pumpAndSettle();
      expect(urls.last, 'mailto:thaivku@gmail.com');
      expect(
        find.textContaining('Unable to open this link.'),
        outcome == 'success' ? findsNothing : findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Contact copies the address from Markdown', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));
    await tester.pumpAndSettle();
    final copy = find.text('Copy email address');
    await tester.ensureVisible(copy);
    await tester.pumpAndSettle();
    await tester.tap(copy);
    await tester.pumpAndSettle();
    expect(copied, 'thaivku@gmail.com');
    expect(find.text('Email address copied.'), findsOneWidget);
  });

  testWidgets('Small portrait and landscape work with double text size', (
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
          home: const PrivacyPolicyPage(),
        ),
      );
      await tester.pumpAndSettle();
      for (final title in [
        '3. Information stored on your device',
        '4. Network requests and service providers',
      ]) {
        final heading = find.text(title);
        await tester.ensureVisible(heading);
        await tester.pumpAndSettle();
        await tester.tap(heading);
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('Copy email address'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
