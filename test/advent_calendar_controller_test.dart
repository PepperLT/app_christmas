import 'dart:async';

import 'package:christmas_countdown/features/advent_calendar/data/advent_progress_service.dart';
import 'package:christmas_countdown/features/advent_calendar/domain/advent_day_repository.dart';
import 'package:christmas_countdown/features/advent_calendar/domain/entity/advent_day.dart';
import 'package:christmas_countdown/features/advent_calendar/presentation/controller/advent_calendar_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/local_advent_days.dart';

class _Repository implements AdventDayRepository {
  final requests = <int>[];
  Future<List<AdventDay>> Function(int) fetch = (_) async => localAdventDays;

  @override
  Future<List<AdventDay>> fetchDays(int year) {
    requests.add(year);
    return fetch(year);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;
  late _Repository repository;
  late DateTime now;
  late AdventCalendarController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repository = _Repository();
    now = DateTime(2026, 12, 5, 12);
    controller = AdventCalendarController(
      progressService: AdventProgressService(preferences),
      dayRepository: repository,
      now: () => now,
    );
  });

  test('Claim rules, stars and persisted progress remain unchanged', () async {
    controller.refreshProgress();
    await Future<void>.delayed(Duration.zero);
    expect(controller.days.length, 25);
    expect(controller.canClaimToday(4), isFalse);
    expect(controller.canClaimToday(6), isFalse);
    expect(await controller.claimDay(4), isFalse);
    expect(await controller.claimDay(5), isTrue);
    expect(await controller.claimDay(5), isFalse);
    expect(controller.totalStars, 10);
    expect(preferences.getStringList('advent_claimed_days_2026'), ['5']);
    controller.refreshProgress();
    expect(controller.isClaimed(5), isTrue);
    expect(repository.requests, [2026]);
    now = DateTime(2026, 11, 5);
    expect(controller.canClaimToday(5), isFalse);
  });

  test(
    'Malformed data and network failure show errors and allow retry',
    () async {
      repository.fetch = (_) async =>
          throw const FormatException('Missing day');
      await controller.loadDays();
      expect(controller.loadError.value, contains('Missing day'));
      expect(controller.days, isEmpty);
      expect(controller.isLoading.value, isFalse);
      repository.fetch = (_) async => throw StateError('Offline');
      await controller.loadDays();
      expect(controller.loadError.value, isNotNull);
      repository.fetch = (_) async => localAdventDays;
      await controller.loadDays();
      expect(controller.loadError.value, isNull);
      expect(controller.days.length, 25);
    },
  );

  test(
    'All boxes stay locked outside December and before their date',
    () async {
      await controller.loadDays();
      for (var month = 1; month < 12; month++) {
        now = DateTime(2026, month, 14, 12);
        controller.refreshProgress();
        for (var day = 1; day <= 25; day++) {
          expect(controller.canClaimToday(day), isFalse);
          expect(await controller.claimDay(day), isFalse);
        }
      }
      now = DateTime(2026, 12, 1, 12);
      controller.refreshProgress();
      expect(controller.canClaimToday(1), isTrue);
      for (var day = 2; day <= 25; day++) {
        expect(controller.canClaimToday(day), isFalse);
        expect(await controller.claimDay(day), isFalse);
      }
      expect(controller.claimedDays, isEmpty);
      expect(preferences.getStringList('advent_claimed_days_2026'), isNull);
    },
  );

  test('An invalid day cannot be claimed but a valid day still can', () async {
    repository.fetch = (_) async => [
      const AdventDay(
        day: 4,
        title: '',
        message: '',
        rewardStars: 0,
        dataError: 'Missing day',
      ),
      localAdventDays[4],
    ];
    await controller.loadDays();
    now = DateTime(2026, 12, 4, 12);
    controller.refreshProgress();
    expect(await controller.claimDay(4), isFalse);
    expect(preferences.getStringList('advent_claimed_days_2026'), isNull);
    now = DateTime(2026, 12, 5, 12);
    expect(await controller.claimDay(5), isTrue);
    expect(controller.totalStars, 10);
  });

  test('Year rollover ignores an older pending response', () async {
    final old = Completer<List<AdventDay>>();
    repository.fetch = (year) =>
        year == 2026 ? old.future : Future.value(localAdventDays);
    controller.refreshProgress();
    now = DateTime(2027, 1, 1);
    controller.refreshProgress();
    await Future<void>.delayed(Duration.zero);
    old.complete([]);
    await Future<void>.delayed(Duration.zero);
    expect(repository.requests, [2026, 2027]);
    expect(controller.days.length, 25);
    expect(controller.claimedDays, isEmpty);
  });
}
