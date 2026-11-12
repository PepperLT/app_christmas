import 'package:get/get.dart';

import '../../domain/bubble_box_board.dart';
import '../../domain/entity/bubble_item.dart';
import '../../../../core/services/sound_effects_service.dart';

class BubbleBoxController extends GetxController {
  BubbleBoxController({BubbleBoxBoard? board})
    : _board = board ?? BubbleBoxBoard();

  final BubbleBoxBoard _board;

  final cells = <BubbleItem?>[].obs;
  final selectedIndex = RxnInt();
  final score = 0.obs;
  final isGameOver = false.obs;
  final rescuesRemaining = 1.obs;
  final canRescue = false.obs;

  void _syncBoard() {
    cells.assignAll(_board.cells);
    isGameOver.value = _board.isGameOver;
    canRescue.value = rescuesRemaining.value > 0 && _board.canRescue;
  }

  void rescueBoard() {
    if (rescuesRemaining.value <= 0 || !_board.rescue()) return;
    rescuesRemaining.value--;
    SoundEffectsService.emit(SoundEffect.rescue);
    selectedIndex.value = null;
    _syncBoard();
  }

  @override
  void onInit() {
    super.onInit();
    _syncBoard();
  }

  void selectCell(int index) {
    if (isGameOver.value || index < 0 || index >= cells.length) return;
    final from = selectedIndex.value;

    if (from == null) {
      if (cells[index] != null) {
        selectedIndex.value = index;
      }
      return;
    }

    selectedIndex.value = null;
    if (from == index) return;

    final upgradedItem = _board.merge(from, index);
    if (upgradedItem == null) return;

    score.value += upgradedItem.level * 10;
    SoundEffectsService.emit(SoundEffect.merge);
    _syncBoard();
  }

  void newGame() {
    _board.reset();
    selectedIndex.value = null;
    score.value = 0;
    rescuesRemaining.value = 1;
    _syncBoard();
  }
}
