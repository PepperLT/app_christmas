// Test doubles only: no Firestore SDK subclass is used in production.
// ignore_for_file: subtype_of_sealed_class

import 'package:christmas_countdown/features/music/data/firestore_song_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class _Document extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _Document(this.id, this.fields);
  @override
  final String id;
  final Map<String, dynamic> fields;
  @override
  Map<String, dynamic> data() => fields;
}

class _Snapshot extends Fake implements QuerySnapshot<Map<String, dynamic>> {
  _Snapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _Collection(this.documents, {this.fail = false});
  final List<_Document> documents;
  final bool fail;
  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    expect(field, 'sortOrder');
    return this;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    if (fail) throw StateError('Query failed');
    return _Snapshot(documents);
  }
}

class _Firestore extends Fake implements FirebaseFirestore {
  _Firestore(this.songs);
  final _Collection songs;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'songs');
    return songs;
  }
}

void main() {
  const valid = <String, dynamic>{
    'title': 'Valid song',
    'imagePath': 'assets/images/song.png',
    'audioPath': 'https://example.com/song.mp3',
  };

  test(
    'Malformed documents do not hide valid songs before and after them',
    () async {
      final repository = FirestoreSongRepository(
        firestore: _Firestore(
          _Collection([
            _Document('first', valid),
            _Document('missing_title', {...valid}..remove('title')),
            _Document('empty_title', {...valid, 'title': '  '}),
            _Document('wrong_title_type', {...valid, 'title': 123}),
            _Document('missing_audio', {...valid}..remove('audioPath')),
            _Document('wrong_image_type', {...valid, 'imagePath': 123}),
            _Document('wrong_premium_type', {...valid, 'isPremium': 'true'}),
            _Document('last', {...valid, 'isPremium': true}),
          ]),
        ),
      );
      final songs = await repository.fetchSongs();
      expect(songs.map((song) => song.id), ['first', 'last']);
      expect(songs.first.isPremium, isFalse);
      expect(songs.last.isPremium, isTrue);
    },
  );

  test(
    'URL aliases still work and surrounding whitespace is trimmed',
    () async {
      final repository = FirestoreSongRepository(
        firestore: _Firestore(
          _Collection([
            _Document('aliases', {
              'title': ' Song ',
              'imageUrl': ' https://example.com/image.png ',
              'audioUrl': ' https://example.com/song.mp3 ',
            }),
          ]),
        ),
      );
      final song = (await repository.fetchSongs()).single;
      expect(song.title, 'Song');
      expect(song.imagePath, 'https://example.com/image.png');
      expect(song.audioPath, 'https://example.com/song.mp3');
    },
  );

  test(
    'Query failures still propagate instead of appearing as empty results',
    () async {
      final repository = FirestoreSongRepository(
        firestore: _Firestore(_Collection([], fail: true)),
      );
      await expectLater(repository.fetchSongs(), throwsStateError);
    },
  );
}
