import 'entity/advent_day.dart';

abstract interface class AdventDayRepository {
  Future<List<AdventDay>> fetchDays(int year);
}
