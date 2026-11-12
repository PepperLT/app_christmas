import 'package:get/get.dart';
import '../domain/premium_plan.dart';

/// Shared plan selection and access state. Store verification is not connected yet.
class PremiumService extends GetxService {
  static PremiumService get instance => Get.isRegistered<PremiumService>()
      ? Get.find<PremiumService>()
      : Get.put(PremiumService(), permanent: true);

  final selectedPlan = PremiumPlan.yearly.obs;
  final _hasPremium = false.obs;

  void selectPlan(PremiumPlan plan) => selectedPlan.value = plan;
  bool get hasPremium => _hasPremium.value;
  Stream<bool> get accessChanges => _hasPremium.stream;

  static bool get isUnlocked =>
      Get.isRegistered<PremiumService>() &&
      Get.find<PremiumService>().hasPremium;
}

class PremiumRequiredException implements Exception {
  const PremiumRequiredException();
}
