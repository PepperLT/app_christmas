import 'package:get/get.dart';

import '../../data/advent_progress_service.dart';
import '../../data/firestore_advent_day_repository.dart';
import '../../domain/advent_day_repository.dart';
import '../../domain/advent_progress_repository.dart';
import '../controller/advent_calendar_controller.dart';

class AdventCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdventDayRepository>(() => FirestoreAdventDayRepository());
    Get.lazyPut<AdventProgressRepository>(
      () => Get.find<AdventProgressService>(),
    );
    Get.lazyPut<AdventCalendarController>(
      () => AdventCalendarController(
        progressService: Get.find<AdventProgressRepository>(),
        dayRepository: Get.find<AdventDayRepository>(),
        // test 1 ô quà ngày đầu tiên
        // now: () => DateTime(2026, 12, 3, 12),
      ),
    );
  }
}
