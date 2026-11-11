import 'package:get/get.dart';

import '../controller/bubble_box_controller.dart';

class BubbleBoxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BubbleBoxController>(() => BubbleBoxController());
  }
}
