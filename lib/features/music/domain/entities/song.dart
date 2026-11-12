class Song {
  const Song({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.audioPath,
    this.isPremium = false,
  });

  final String id;
  final String title;
  final String imagePath;
  final String audioPath;
  final bool isPremium;
}
