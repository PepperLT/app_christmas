// SDK fakes are used only to verify query paths and malformed data handling.
// ignore_for_file: subtype_of_sealed_class

import 'package:christmas_countdown/features/advent_calendar/data/firestore_advent_day_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class _Document extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _Document(this.fields);
  final Map<String, dynamic> fields;
  @override
  String get id => '01';
  @override
  Map<String, dynamic> data() => fields;
  @override
  DocumentReference<Map<String, dynamic>> get reference => _Reference();
}

class _Reference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  String get path => 'advent_calendars/2026/days/01';
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'days');
    return _Collection();
  }
}

class _Snapshot extends Fake implements QuerySnapshot<Map<String, dynamic>> {
  _Snapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    expect(path, '2026');
    return _Reference();
  }
}

class _Days extends _Collection {
  _Days(this.documents);
  final List<_Document> documents;
  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    expect(field, 'day');
    return this;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async => _Snapshot(documents);
}

class _CalendarReference extends _Reference {
  _CalendarReference(this.days);
  final _Days days;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'days');
    return days;
  }
}

class _Calendars extends _Collection {
  _Calendars(this.days);
  final _Days days;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    expect(path, '2026');
    return _CalendarReference(days);
  }
}

class _Firestore extends Fake implements FirebaseFirestore {
  _Firestore(this.documents);
  final List<_Document> documents;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'advent_calendars');
    return _Calendars(_Days(documents));
  }
}

void main() {
  List<_Document> validDays() => List.generate(
    25,
    (index) => _Document({
      'day': index + 1,
      'title': ' Title ',
      'message': ' Message ',
      'rewardStars': index + 1,
    }),
  );

  Future<dynamic> fetch(List<_Document> docs) =>
      FirestoreAdventDayRepository(firestore: _Firestore(docs)).fetchDays(2026);

  test('Reads year-specific days and maps content and rewards', () async {
    final days = await fetch(validDays());
    expect(days.length, 25);
    expect(days.first.title, 'Title');
    expect(days.last.rewardStars, 25);
  });

  test('Missing days affect only their slots', () async {
    final days = await fetch(validDays()..removeAt(4));
    expect(days.length, 25);
    expect(days[4].dataError, isNotNull);
    expect(days[3].dataError, isNull);
    expect(days[5].dataError, isNull);
    final empty = await fetch([]);
    expect(empty.every((dynamic day) => day.dataError != null), isTrue);
  });

  test('Duplicates affect only the duplicated and missing days', () async {
    final docs = validDays();
    docs.last.fields['day'] = 1;
    final days = await fetch(docs);
    expect(days.first.dataError, isNotNull);
    expect(days.last.dataError, isNotNull);
    expect(days[1].dataError, isNull);
  });

  for (final field in ['day', 'title', 'message', 'rewardStars']) {
    test('Missing or invalid $field does not hide other days', () async {
      for (final value in [null, false]) {
        final docs = validDays();
        docs.first.fields[field] = value;
        final days = await fetch(docs);
        expect(days.first.dataError, isNotNull);
        expect(
          days.skip(1).every((dynamic day) => day.dataError == null),
          isTrue,
        );
      }
    });
  }
}
