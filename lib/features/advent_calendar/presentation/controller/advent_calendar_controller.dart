import 'package:get/get.dart';

import '../../domain/advent_progress_repository.dart';
import '../../domain/advent_day_repository.dart';
import '../../domain/entity/advent_day.dart';
import '../../../../core/services/sound_effects_service.dart';

class AdventCalendarController extends GetxController {
  AdventCalendarController({
    required AdventProgressRepository progressService,
    required AdventDayRepository dayRepository,
    DateTime Function()? now,
  }) : _progressService = progressService,
       _dayRepository = dayRepository,
       _now = now ?? DateTime.now;

  final AdventProgressRepository _progressService;
  final AdventDayRepository _dayRepository;
  final DateTime Function() _now;

  final days = <AdventDay>[].obs;
  final isLoading = false.obs;
  final loadError = RxnString();
  int? _contentYear;
  int _requestId = 0;
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
    if (_contentYear != today.year) {
      loadDays();
    }
  }

  Future<void> loadDays() async {
    final year = _now().year;
    final requestId = ++_requestId;
    if (_contentYear != year) days.clear();
    _contentYear = year;
    isLoading.value = true;
    loadError.value = null;
    errorMessage.value = null;
    try {
      final loaded = await _dayRepository.fetchDays(year);
      if (isClosed || requestId != _requestId) return;
      days.assignAll(loaded);
    } on FormatException catch (error) {
      if (isClosed || requestId != _requestId) return;
      loadError.value = 'Dữ liệu lịch $year không hợp lệ: ${error.message}';
    } catch (_) {
      if (isClosed || requestId != _requestId) return;
      loadError.value =
          'Không thể tải lịch $year. Kiểm tra kết nối rồi thử lại.';
    } finally {
      if (!isClosed && requestId == _requestId) isLoading.value = false;
    }
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

  String? errorForDay(int day, {bool allowClaimed = false}) {
    final today = _now();
    final item = days.firstWhereOrNull((item) => item.day == day);
    if (_contentYear != today.year || item == null) {
      return 'Ngày $day chưa có dữ liệu hợp lệ.';
    }
    if (item.dataError != null) return item.dataError;
    if (isClaimed(day)) {
      return allowClaimed ? null : 'Bạn đã nhận quà ngày $day rồi.';
    }
    if (day < 1 || day > 25) return 'Ngày nhận quà không hợp lệ.';
    if (today.month != 12)
      return 'Chỉ được nhận quà từ ngày 1 đến 25 tháng 12.';
    if (day > today.day) return 'Chưa đến ngày $day để nhận quà.';
    if (day < today.day) return 'Đã bỏ lỡ quà ngày $day, không thể nhận bù.';
    return null;
  }

  Future<bool> claimDay(int day) async {
    if (isClaiming.value) return false;
    errorMessage.value = null;

    final today = _now();

    if (_loadedYear != today.year) {
      _loadYear(today.year);
    }

    errorMessage.value = errorForDay(day);
    if (errorMessage.value != null) return false;

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

      SoundEffectsService.emit(SoundEffect.reward);
      return true;
    } catch (_) {
      errorMessage.value = 'Không thể lưu tiến độ. Hãy thử lại.';
      return false;
    } finally {
      isClaiming.value = false;
    }
  }
}
