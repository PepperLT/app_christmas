import 'entities/song.dart';

/// Source-independent catalog contract.
abstract interface class SongRepository {
  Future<List<Song>> fetchSongs();
}
