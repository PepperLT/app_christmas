class AdventDay {
  final int day;
  final String title;
  final String message;
  final String? imageAsset;
  final int rewardStars;
  final String? dataError;

  const AdventDay({
    required this.day,
    required this.title,
    required this.message,
    this.imageAsset,
    this.rewardStars = 10,
    this.dataError,
  });
}
