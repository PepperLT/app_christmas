import 'dart:async';
import 'package:christmas_countdown/app/startup_app.dart';
import 'package:christmas_countdown/app/startup_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Retry resumes failed essential step without duplicating completed services',
    () async {
      var firebase = 0;
      var preferences = 0;
      var services = 0;
      final initializer = StartupInitializer(
        essential: [
          StartupStep('Firebase', () async {
            firebase++;
          }),
          StartupStep('Preferences', () async {
            if (++preferences == 1) throw StateError('Storage unavailable');
          }),
          StartupStep('Services', () async {
            services++;
          }),
        ],
        onOptionalError: (_, _, _) {},
      );
      await expectLater(initializer.initialize(), throwsStateError);
      expect(services, 0);
      await initializer.initialize();
      await initializer.initialize();
      expect([firebase, preferences, services], [1, 2, 1]);
    },
  );

  test('Concurrent initialize calls share one in-flight operation', () async {
    final pending = Completer<void>();
    var calls = 0;
    final initializer = StartupInitializer(
      essential: [
        StartupStep('Firebase', () {
          calls++;
          return pending.future;
        }),
      ],
      onOptionalError: (_, _, _) {},
    );
    final first = initializer.initialize();
    final second = initializer.initialize();
    expect(identical(first, second), isTrue);
    expect(calls, 1);
    pending.complete();
    await first;
  });

  test(
    'Every essential initialization failure propagates and can be retried',
    () async {
      for (final name in ['Firebase', 'Preferences', 'Services']) {
        var fail = true;
        final initializer = StartupInitializer(
          essential: [
            StartupStep(name, () async {
              if (fail) throw StateError(name);
            }),
          ],
          onOptionalError: (_, _, _) {},
        );
        await expectLater(initializer.initialize(), throwsStateError);
        fail = false;
        await initializer.initialize();
      }
    },
  );

  test(
    'Optional failure or pending initialization never blocks the app or retries itself',
    () async {
      final pending = Completer<void>();
      var optionalCalls = 0;
      final failures = <String>[];
      final initializer = StartupInitializer(
        essential: [],
        optional: [
          StartupStep('Supabase failure', () async {
            optionalCalls++;
            throw StateError('Offline');
          }),
          StartupStep('Supabase pending', () {
            optionalCalls++;
            return pending.future;
          }),
        ],
        onOptionalError: (name, _, _) {
          failures.add(name);
        },
      );
      await initializer.initialize();
      await initializer.initialize();
      expect(optionalCalls, 2);
      expect(failures, ['Supabase failure']);
      pending.complete();
    },
  );

  testWidgets(
    'Startup error shows Retry and repeated taps start only one attempt',
    (tester) async {
      var calls = 0;
      final pending = Completer<void>();
      final initializer = StartupInitializer(
        essential: [
          StartupStep('Preferences', () {
            calls++;
            if (calls == 1) {
              return Future.error(StateError('Storage unavailable'));
            }
            return pending.future;
          }),
        ],
        onOptionalError: (_, _, _) {},
      );
      await tester.pumpWidget(
        StartupApp(
          initializer: initializer,
          appBuilder: (_) => const MaterialApp(home: Text('Ready')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Unable to start'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(calls, 2);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('Ready'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Completing initialization after disposal does not update UI', (
    tester,
  ) async {
    final pending = Completer<void>();
    final initializer = StartupInitializer(
      essential: [StartupStep('Firebase', () => pending.future)],
      onOptionalError: (_, _, _) {},
    );
    await tester.pumpWidget(
      StartupApp(
        initializer: initializer,
        appBuilder: (_) => const MaterialApp(home: Text('Ready')),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
