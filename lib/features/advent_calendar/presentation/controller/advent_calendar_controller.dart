import 'package:get/get.dart';

import '../../data/advent_progress_service.dart';
import '../../data/local_advent_days.dart';

class AdventCalendarController extends GetxController {
  AdventCalendarController({
    required AdventProgressService progressService,
    DateTime Function()? now,
  }) : _progressService = progressService,
       _now = now ?? DateTime.now;

  final AdventProgressService _progressService;
  final DateTime Function() _now;

  final days = localAdventDays;
  final claimedDays = <int>{}.obs;
  final isClaiming = false.obs;
  final errorMessage = RxnString();
  final currentDate = DateTime.now().obs;

  int? _loadedYear;

  @override
  void onInit() {
    super.onInit();
    refreshProgress();
  }

  // Gọi thêm khi ứng dụng trở lại từ nền để cập nhật năm.
  void refreshProgress() {
    final today = _now();
    currentDate.value = today;
    _loadYear(today.year);
  }

  bool isMissed(int day) {
    final today = currentDate.value;
    return !isClaimed(day) && today.isAfter(DateTime(today.year, 12, day + 1));
  }

  void _loadYear(int year) {
    claimedDays
      ..clear()
      ..addAll(_progressService.loadClaimedDays(year));

    _loadedYear = year;
  }

  bool isClaimed(int day) => claimedDays.contains(day);

  bool canClaimToday(int day) {
    final today = _now();

    return !isClaiming.value &&
        today.month == 12 &&
        day >= 1 &&
        day <= 25 &&
        day == today.day &&
        (_loadedYear != today.year || !isClaimed(day));
  }

  int get claimedCount => claimedDays.length;

  int get totalStars => days
      .where((day) => isClaimed(day.day))
      .fold<int>(0, (total, day) => total + day.rewardStars);

  Future<bool> claimDay(int day) async {
    if (isClaiming.value) return false;

    final today = _now();

    if (_loadedYear != today.year) {
      _loadYear(today.year);
    }

    if (today.month != 12 ||
        day < 1 ||
        day > 25 ||
        day != today.day ||
        isClaimed(day)) {
      return false;
    }

    isClaiming.value = true;
    errorMessage.value = null;

    try {
      final updatedDays = {...claimedDays, day};

      await _progressService.saveClaimedDays(today.year, updatedDays);

      // Cập nhật giao diện sau khi lưu thành công.
      if (_now().year == today.year) {
        claimedDays
          ..clear()
          ..addAll(updatedDays);
      } else {
        refreshProgress();
      }

      return true;
    } catch (_) {
      errorMessage.value = 'Không thể lưu tiến độ. Hãy thử lại.';
      return false;
    } finally {
      isClaiming.value = false;
    }
  }
}
