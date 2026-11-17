import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/advent_day_repository.dart';
import '../domain/entity/advent_day.dart';

class FirestoreAdventDayRepository implements AdventDayRepository {
  FirestoreAdventDayRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<AdventDay>> fetchDays(int year) async {
    final snapshot = await _firestore
        .collection('advent_calendars')
        .doc(year.toString())
        .collection('days')
        .get();

    final days = <int, AdventDay>{};
    final seenDays = <int>{};

    AdventDay failed(int day, String error) => AdventDay(
      day: day,
      title: 'Data Error',
      message: error,
      rewardStars: 0,
      dataError: error,
    );

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final day = data['day'];
      final title = data['title'];
      final message = data['message'];
      final rewardStars = data['rewardStars'];

      if (day is! int || day < 1 || day > 25) {
        final idDay = int.tryParse(doc.id);
        if (idDay != null && idDay >= 1 && idDay <= 25) {
          seenDays.add(idDay);
          days[idDay] = failed(idDay, 'Day $idDay has an invalid day field.');
        }
        continue;
      }

      if (!seenDays.add(day)) {
        days[day] = failed(day, 'Duplicate content for December $day.');
        continue;
      }

      if (title is! String || title.trim().isEmpty) {
        days[day] = failed(day, 'Missing a valid title for December $day.');
        continue;
      }

      if (message is! String || message.trim().isEmpty) {
        days[day] = failed(day, 'Missing a valid message for December $day.');
        continue;
      }

      if (rewardStars is! int || rewardStars < 0) {
        days[day] = failed(day, 'Invalid reward stars for December $day.');
        continue;
      }

      days[day] = AdventDay(
        day: day,
        title: title.trim(),
        message: message.trim(),
        rewardStars: rewardStars,
      );
    }

    return List.generate(25, (index) {
      final day = index + 1;
      return days[day] ?? failed(day, 'No data available for December $day.');
    });
  }
}
