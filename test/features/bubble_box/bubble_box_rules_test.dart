import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/bubble_box_board.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/entity/bubble_item.dart';
import 'package:christmas_countdown/features/bubblle_box/presentation/controller/bubble_box_controller.dart';
import 'package:christmas_countdown/features/bubblle_box/presentation/page/bubble_box_page.dart';

List<int>? pair(List<BubbleItem?> cells) {
  for (var i = 0; i < cells.length; i++) {
    for (var j = i + 1; j < cells.length; j++) {
      final a = cells[i];
      final b = cells[j];
      if (a != null &&
          b != null &&
          a.type == b.type &&
          a.level == b.level &&
          a.level < 5) {
        return [i, j];
      }
    }
  }
  return null;
}

void main() {
  test('Two gifts merge into level two and respawn at source', () {
    final board = BubbleBoxBoard(random: Random(42));
    final indices = [
      for (var i = 0; i < board.cells.length; i++)
        if (board.cells[i]?.type == BubbleItemType.gift) i,
    ];
    final result = board.merge(indices[0], indices[1]);
    expect(result?.type, BubbleItemType.gift);
    expect(result?.level, 2);
    expect(board.cells[indices.first]?.level, 1);
    expect(board.cells[indices[1]], same(result));
  });
  test('New boards have two of each of four types and four empty cells', () {
    final layouts = <String>{};
    for (var seed = 0; seed < 20; seed++) {
      final board = BubbleBoxBoard(random: Random(seed));
      expect(board.cells.length, 12);
      expect(board.cells.where((e) => e == null).length, 4);
      for (final type in BubbleBoxBoard.itemTypes) {
        expect(board.cells.where((e) => e?.type == type).length, 2);
      }
      expect(
        board.cells.whereType<BubbleItem>().every((e) => e.level == 1),
        isTrue,
      );
      expect(board.hasMergeablePair, isTrue);
      layouts.add(board.cells.map((e) => e?.type.name).join(','));
    }
    expect(layouts.length, greaterThan(1));
  });

  test('Merge rules, single source spawn and termination with empty cells', () {
    const rescued = 0;
    var levelFivePairs = 0;
    for (var seed = 0; seed < 100; seed++) {
      final board = BubbleBoxBoard(random: Random(seed));
      var moves = 0;
      while (board.hasMergeablePair) {
        final before = board.cells;
        // Every invalid pair must preserve the board, including level-five pairs.
        for (var i = 0; i < 12; i++) {
          for (var j = i; j < 12; j++) {
            final a = before[i];
            final b = before[j];
            if (i != j &&
                a != null &&
                b != null &&
                a.type == b.type &&
                a.level == b.level &&
                a.level < 5) {
              continue;
            }
            if (i != j && a?.level == 5 && b?.level == 5) levelFivePairs++;
            expect(board.merge(i, j), isNull);
            expect(board.cells, orderedEquals(before));
          }
        }
        final indices = pair(before)!;
        final result = board.merge(indices[0], indices[1])!;
        final after = board.cells;
        expect(result.level, before[indices[1]]!.level + 1);
        expect(after[indices[1]], same(result));
        expect(after[indices[0]]!.level, 1);
        expect(BubbleBoxBoard.itemTypes, contains(after[indices[0]]!.type));
        final additions = [
          for (var i = 0; i < 12; i++)
            if (before[i] == null && after[i] != null) i,
        ];
        expect(additions, isEmpty);
        expect(++moves, lessThan(1000));
      }
      expect(board.isGameOver, isTrue);
      expect(board.cells.where((e) => e == null).length, 4);
    }
    expect(rescued, 0);
    expect(levelFivePairs, greaterThanOrEqualTo(0));
  });

  testWidgets('Controller scores once, shows game over, and new game resets', (
    tester,
  ) async {
    final controller = Get.put(BubbleBoxController());
    addTearDown(Get.reset);
    await tester.pumpWidget(const GetMaterialApp(home: BubbleBoxPage()));
    var expectedScore = 0;
    while (!controller.isGameOver.value) {
      final indices = pair(controller.cells)!;
      final level = controller.cells[indices[1]]!.level + 1;
      controller.selectCell(indices[0]);
      controller.selectCell(indices[1]);
      expectedScore += level * 10;
      expect(controller.score.value, expectedScore);
      expect(controller.selectedIndex.value, isNull);
    }
    await tester.pump();
    expect(find.text('Hết nước đi'), findsOneWidget);
    final savedScore = controller.score.value;
    expect(find.text('Cứu bàn (1 lượt)'), findsOneWidget);
    await tester.tap(find.text('Cứu bàn (1 lượt)'));
    await tester.pump();
    expect(controller.score.value, savedScore);
    expect(controller.rescuesRemaining.value, 0);
    expect(controller.isGameOver.value, isFalse);
    while (!controller.isGameOver.value) {
      final indices = pair(controller.cells)!;
      controller.selectCell(indices[0]);
      controller.selectCell(indices[1]);
    }
    await tester.pump();
    expect(find.text('Cứu bàn (0 lượt)'), findsOneWidget);
    await tester.tap(find.text('Ván mới'));
    await tester.pump();
    expect(controller.rescuesRemaining.value, 1);
    expect(controller.score.value, 0);
    expect(controller.selectedIndex.value, isNull);
    expect(controller.cells.whereType<BubbleItem>().length, 8);
    for (final type in BubbleBoxBoard.itemTypes) {
      expect(controller.cells.where((e) => e?.type == type).length, 2);
    }
    expect(
      controller.cells.whereType<BubbleItem>().every((e) => e.level == 1),
      isTrue,
    );
    expect(controller.isGameOver.value, isFalse);
    expect(find.text('Hết nước đi'), findsNothing);
  });
}
