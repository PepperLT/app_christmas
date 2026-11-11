import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/bubble_box_board.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/entity/bubble_item.dart';
import 'package:christmas_countdown/features/bubblle_box/presentation/controller/bubble_box_controller.dart';

void main() {
  test('Rescue works immediately, keeps score and resets with new game', () {
    final controller = BubbleBoxController()..onInit();
    expect(controller.isGameOver.value, isFalse);
    expect(controller.canRescue.value, isTrue);
    controller.selectCell(controller.cells.indexWhere((item) => item != null));
    controller.rescueBoard();
    expect(controller.cells.whereType<BubbleItem>().length, 9);
    expect(controller.selectedIndex.value, isNull);
    expect(controller.score.value, 0);
    expect(controller.rescuesRemaining.value, 0);
    final before = controller.cells.toList();
    controller.rescueBoard();
    expect(controller.cells, orderedEquals(before));
    controller.newGame();
    expect(controller.cells.whereType<BubbleItem>().length, 8);
    expect(controller.rescuesRemaining.value, 1);
    expect(controller.canRescue.value, isTrue);
    controller.onClose();
  });
  test(
    'Rescue uses empty cells or replaces lowest other level on full board',
    () {
      for (final full in [false, true]) {
        final items = [
          for (final type in BubbleBoxBoard.itemTypes)
            for (var level = 2; level <= 4; level++)
              BubbleItem(type: type, level: level),
        ];
        if (!full) items.removeRange(8, 12);
        final board = BubbleBoxBoard.forTesting([
          ...items,
          if (!full) ...List<BubbleItem?>.filled(4, null),
        ], random: Random(42));
        final controller = BubbleBoxController(board: board)..onInit();
        expect(controller.isGameOver.value, isTrue);
        final before = board.cells;
        controller.rescueBoard();
        expect(board.hasMergeablePair, isTrue);
        expect(controller.isGameOver.value, isFalse);
        expect(controller.rescuesRemaining.value, 0);
        expect(controller.score.value, 0);
        final changed = [
          for (var i = 0; i < 12; i++)
            if (before[i] != board.cells[i]) i,
        ];
        expect(changed.length, 1);
        if (full) {
          expect(before[changed.single]!.level, 2);
        } else {
          expect(before[changed.single], isNull);
        }
        var turns = 0;
        while (!controller.isGameOver.value) {
          final cells = controller.cells;
          List<int>? pair;
          for (var i = 0; i < 12 && pair == null; i++) {
            for (var j = i + 1; j < 12; j++) {
              final a = cells[i];
              final b = cells[j];
              if (a != null &&
                  b != null &&
                  a.type == b.type &&
                  a.level == b.level &&
                  a.level < 5) {
                pair = [i, j];
                break;
              }
            }
          }
          final score = controller.score.value;
          final level = cells[pair![1]]!.level + 1;
          controller.selectCell(pair[0]);
          controller.selectCell(pair[1]);
          expect(controller.score.value, score + level * 10);
          expect(++turns, lessThan(1000));
        }
        expect(controller.canRescue.value, isFalse);
        final stopped = controller.cells.toList();
        controller.rescueBoard();
        expect(controller.cells, orderedEquals(stopped));
        controller.newGame();
        expect(controller.rescuesRemaining.value, 1);
        expect(controller.score.value, 0);
        expect(controller.selectedIndex.value, isNull);
        expect(controller.cells.whereType<BubbleItem>().length, 8);
        controller.onClose();
      }
    },
  );
  test('Level five only board cannot use rescue', () {
    final board = BubbleBoxBoard.forTesting(
      List.filled(12, const BubbleItem(type: BubbleItemType.tree, level: 5)),
    );
    final controller = BubbleBoxController(board: board)..onInit();
    expect(controller.canRescue.value, isFalse);
    controller.rescueBoard();
    expect(controller.rescuesRemaining.value, 1);
    expect(board.merge(0, 1), isNull);
    controller.onClose();
  });
}
