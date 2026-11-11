import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/bubble_box_board.dart';
import 'package:christmas_countdown/features/bubblle_box/domain/entity/bubble_item.dart';

void main() {
  test('Successful merge upgrades target and respawns at source', () {
    final board = BubbleBoxBoard(random: Random(42));
    final before = board.cells;
    final trees = [
      for (var i = 0; i < before.length; i++)
        if (before[i]?.type == BubbleItemType.tree) i,
    ];
    final upgraded = board.merge(trees.first, trees.last);
    expect(upgraded?.type, BubbleItemType.tree);
    expect(upgraded?.level, 2);
    expect(board.cells[trees.last], same(upgraded));
    expect(board.cells[trees.first]?.level, 1);
    expect(board.cells.whereType<BubbleItem>().length, 8);
    for (var i = 0; i < before.length; i++) {
      if (!trees.contains(i)) expect(board.cells[i], same(before[i]));
    }
  });

  test('Invalid merges preserve all items', () {
    final board = BubbleBoxBoard(random: Random(42));
    final before = board.cells;
    final tree = before.indexWhere((e) => e?.type == BubbleItemType.tree);
    final gift = before.indexWhere((e) => e?.type == BubbleItemType.gift);
    final empty = before.indexOf(null);
    for (final pair in [
      [tree, gift],
      [tree, tree],
      [tree, empty],
      [-1, tree],
      [tree, 12],
    ]) {
      expect(board.merge(pair[0], pair[1]), isNull);
      expect(board.cells, orderedEquals(before));
    }
  });
}
