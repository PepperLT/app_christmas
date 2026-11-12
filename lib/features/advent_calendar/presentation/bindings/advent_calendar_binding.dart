import 'package:get/get.dart';

import '../../data/advent_progress_service.dart';
import '../controller/advent_calendar_controller.dart';

class AdventCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdventCalendarController>(
      () => AdventCalendarController(
        progressService: Get.find<AdventProgressService>(),
        // test 1 ô quà ngày đầu tiên
        // now: () => DateTime(2026, 12, 1, 12),
      ),
    );
  }
}
