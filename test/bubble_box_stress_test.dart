import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/bubble_box_board.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/entity/bubble_item.dart';
import 'package:christmas_countdown/features/bubblle_box/presentation/controller/bubble_box_controller.dart';

void main() {
  test('1000 random games never get stuck before game over', () {
    var totalMoves = 0;
    var shortest = 10000;
    var longest = 0;
    for (var seed = 0; seed < 1000; seed++) {
      final random = Random(seed);
      final board = BubbleBoxBoard(random: Random(seed));
      var moves = 0;
      while (!board.isGameOver) {
        final cells = board.cells;
        final pairs = <List<int>>[];
        for (var i = 0; i < 12; i++) {
          for (var j = i + 1; j < 12; j++) {
            final a = cells[i];
            final b = cells[j];
            if (a != null &&
                b != null &&
                a.type == b.type &&
                a.level == b.level &&
                a.level < 5) {
              pairs.add([i, j]);
            }
          }
        }
        expect(pairs, isNotEmpty, reason: 'Stuck at seed $seed, move $moves');
        final chosen = pairs[random.nextInt(pairs.length)];
        if (random.nextBool()) {
          final temp = chosen[0];
          chosen[0] = chosen[1];
          chosen[1] = temp;
        }
        expect(board.merge(chosen[0], chosen[1]), isNotNull);
        expect(board.cells.length, 12);
        expect(
          board.cells.whereType<BubbleItem>().every(
            (e) =>
                e.level >= 1 &&
                e.level <= 5 &&
                BubbleBoxBoard.itemTypes.contains(e.type),
          ),
          isTrue,
        );
        expect(++moves, lessThan(1000));
      }
      expect(board.cells.where((e) => e == null).length, 4);
      expect(board.hasMergeablePair, isFalse);
      board.reset();
      expect(board.cells.whereType<BubbleItem>().length, 8);
      expect(board.isGameOver, isFalse);
      totalMoves += moves;
      shortest = min(shortest, moves);
      longest = max(longest, moves);
    }
    // ignore: avoid_print
    print(
      '1000 games: $totalMoves merges; min=$shortest, max=$longest, average=${totalMoves / 1000}',
    );
  });

  test(
    'Controller ignores invalid taps and invalid merges without scoring',
    () {
      final controller = BubbleBoxController();
      controller.onInit();
      final before = controller.cells.toList();
      final source = before.indexWhere((e) => e != null);
      final different = before.indexWhere(
        (e) => e != null && e.type != before[source]!.type,
      );
      final empty = before.indexOf(null);
      for (final target in [source, different, empty]) {
        controller.selectCell(source);
        controller.selectCell(target);
        expect(controller.cells, orderedEquals(before));
        expect(controller.score.value, 0);
        expect(controller.selectedIndex.value, isNull);
      }
      controller.selectCell(-1);
      controller.selectCell(12);
      expect(controller.cells, orderedEquals(before));
      expect(controller.score.value, 0);
      controller.selectCell(source);
      controller.newGame();
      expect(controller.selectedIndex.value, isNull);
      expect(controller.score.value, 0);
      controller.onClose();
    },
  );
}
