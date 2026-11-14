import 'package:shared_preferences/shared_preferences.dart';

import '../domain/advent_progress_repository.dart';

class AdventProgressService implements AdventProgressRepository {
  AdventProgressService(this._preferences);

  final SharedPreferences _preferences;

  String _key(int year) => 'advent_claimed_days_$year';

  @override
  Set<int> loadClaimedDays(int year) {
    final values = _preferences.getStringList(_key(year)) ?? [];

    return values
        .map(int.tryParse)
        .whereType<int>()
        .where((day) => day >= 1 && day <= 25)
        .toSet();
  }

  @override
  Future<void> saveClaimedDays(int year, Set<int> days) async {
    final sortedDays = days.toList()..sort();

    final saved = await _preferences.setStringList(
      _key(year),
      sortedDays.map((day) => day.toString()).toList(),
    );

    if (!saved) {
      throw StateError('Không thể lưu tiến độ nhận quà.');
    }
  }
}
