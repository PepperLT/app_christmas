enum BubbleItemType {
  tree,
  gift,
  bell,
  stocking,
  snowman,
  gingerbread,
  candyCane,
  reindeer,
  santa,
  snowflake,
}

class BubbleItem {
  const BubbleItem({required this.type, required this.level});

  final BubbleItemType type;
  final int level;
}
