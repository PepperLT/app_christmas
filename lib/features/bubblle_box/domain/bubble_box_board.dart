import 'dart:math';
import 'package:flutter/foundation.dart';

import 'entity/bubble_item.dart';

class BubbleBoxBoard {
  BubbleBoxBoard({Random? random}) : _random = random ?? Random() {
    reset();
  }

  @visibleForTesting
  BubbleBoxBoard.forTesting(List<BubbleItem?> cells, {Random? random})
    : _random = random ?? Random() {
    if (cells.length != 12) throw ArgumentError('Board must have 12 cells');
    _cells.addAll(cells);
  }

  final Random _random;
  static const maxLevel = 5;
  static const itemTypes = [
    BubbleItemType.tree,
    BubbleItemType.gift,
    BubbleItemType.bell,
    BubbleItemType.stocking,
  ];
  final List<BubbleItem?> _cells = [];

  List<BubbleItem?> get cells => List.unmodifiable(_cells);

  void reset() {
    _cells
      ..clear()
      ..addAll([
        for (final type in itemTypes)
          for (var i = 0; i < 2; i++) BubbleItem(type: type, level: 1),
        ...List<BubbleItem?>.filled(4, null),
      ])
      ..shuffle(_random);
  }

  bool get hasMergeablePair {
    for (var i = 0; i < _cells.length; i++) {
      for (var j = i + 1; j < _cells.length; j++) {
        if (_canMerge(_cells[i], _cells[j])) return true;
      }
    }
    return false;
  }

  bool get isGameOver => !hasMergeablePair;

  bool _canMerge(BubbleItem? source, BubbleItem? target) =>
      source != null &&
      target != null &&
      source.type == target.type &&
      source.level == target.level &&
      source.level < maxLevel;

  BubbleItem? merge(int from, int to) {
    if (from == to ||
        from < 0 ||
        from >= _cells.length ||
        to < 0 ||
        to >= _cells.length) {
      return null;
    }

    final source = _cells[from];
    final target = _cells[to];
    if (!_canMerge(source, target)) return null;

    final upgradedItem = BubbleItem(
      type: target!.type,
      level: target.level + 1,
    );
    _cells[from] = null;
    _cells[to] = upgradedItem;

    final preferredTypes = _cells
        .whereType<BubbleItem>()
        .where((item) => item.level == 1 && itemTypes.contains(item.type))
        .map((item) => item.type)
        .toSet()
        .toList();
    final choices = preferredTypes.isNotEmpty && _random.nextDouble() < 0.7
        ? preferredTypes
        : itemTypes;
    final spawned = BubbleItem(
      type: choices[_random.nextInt(choices.length)],
      level: 1,
    );
    _cells[from] = spawned;

    return upgradedItem;
  }

  bool get canRescue =>
      _cells.any((item) => item != null && item.level < maxLevel);

  bool rescue() {
    if (!canRescue) return false;
    final sources = [
      for (var i = 0; i < _cells.length; i++)
        if (_cells[i] != null && _cells[i]!.level < maxLevel) i,
    ];
    final source = sources[_random.nextInt(sources.length)];
    final empty = [
      for (var i = 0; i < _cells.length; i++)
        if (_cells[i] == null) i,
    ];
    final targets = empty.isNotEmpty
        ? empty
        : [
            for (var i = 0; i < _cells.length; i++)
              if (i != source) i,
          ];
    if (empty.isEmpty) {
      final lowest = targets.map((i) => _cells[i]!.level).reduce(min);
      targets.removeWhere((i) => _cells[i]!.level != lowest);
    }
    if (targets.isEmpty) return false;
    final item = _cells[source]!;
    _cells[targets[_random.nextInt(targets.length)]] = BubbleItem(
      type: item.type,
      level: item.level,
    );
    return hasMergeablePair;
  }
}
