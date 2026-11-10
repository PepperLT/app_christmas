import 'package:get/get.dart';

import '../../data/advent_progress_service.dart';
import '../controller/advent_calendar_controller.dart';

class AdventCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdventCalendarController>(
      () => AdventCalendarController(
        progressService: Get.find<AdventProgressService>(),
      ),
    );
  }
}
