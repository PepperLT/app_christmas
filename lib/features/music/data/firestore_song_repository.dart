import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/song.dart';
import '../domain/song_repository.dart';

/// Reads song metadata and maps Firestore documents into domain entities.
class FirestoreSongRepository implements SongRepository {
  FirestoreSongRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Song>> fetchSongs() async {
    final snapshot = await _firestore
        .collection('songs')
        .orderBy('sortOrder')
        .get();

    final songs = <Song>[];
    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final title = data['title'];
        if (title is! String || title.trim().isEmpty) {
          throw const FormatException('title must be a non-empty string.');
        }
        final premium = data['isPremium'];
        if (premium != null && premium is! bool) {
          throw const FormatException('isPremium must be a boolean.');
        }
        songs.add(
          Song(
            id: doc.id,
            title: title.trim(),
            imagePath: _readSource(data, 'imagePath', 'imageUrl', doc.id),
            audioPath: _readSource(data, 'audioPath', 'audioUrl', doc.id),
            isPremium: premium as bool? ?? false,
          ),
        );
      } on FormatException catch (error, stackTrace) {
        developer.log(
          'Skipping invalid song: songs/${doc.id}',
          name: 'music.FirestoreSongRepository',
          level: 900,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return songs;
  }

  // Accept URL fields as well as the original asset-path fields.
  static String _readSource(
    Map<String, dynamic> data,
    String pathField,
    String urlField,
    String songId,
  ) {
    for (final field in [pathField, urlField]) {
      final value = data[field];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    throw FormatException('Song $songId requires $pathField or $urlField.');
  }
}
