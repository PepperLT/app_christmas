# Music: reading guide

Start with these two flows:

```text
LOAD CATALOG
MusicPage -> MusicController -> SongRepository -> FirestoreSongRepository

PLAY AUDIO
MusicPage / SongDetailController -> MusicController
                                -> MusicPlayer -> JustAudioMusicPlayer
```

## Files and responsibilities

- domain/entities/song.dart: immutable song metadata, independent of frameworks.
- domain/song_repository.dart: contract for fetching song metadata.
- domain/music_player.dart: contract for playback operations and streams.
- data/firestore_song_repository.dart: one place for the Firestore query and
  document-to-Song conversion. There is no extra data source or model layer.
- data/just_audio_music_player.dart: adapts just_audio to MusicPlayer.
- presentation/controllers/music_controller.dart: shared catalog/playback state,
  switch, selection, retry, request serialization and lifecycle management.
- presentation/controllers/song_detail_controller.dart: state for one song,
  position/duration subscriptions and detail actions.
- presentation/page/: existing screen layouts and navigation.
- presentation/widgets/song_progress.dart: slider interaction and time display.
- presentation/bindings/song_detail_binding.dart: creates a tagged detail controller.
- music_dependencies.dart: wires audio and Premium into the shared controller.
  Premium access is injected as a function plus a stream factory, not separate
  policy classes. The stream is resolved on initialization as before.

## Dependency wiring

main.dart imports FirestoreSongRepository directly to load the catalog.
main.dart, Settings and tests import MusicPlayerService directly from
music_dependencies.dart.

MusicPlayerService inherits shared controller behavior and does not create an
additional controller or player. The private loader adapter in dependencies
supports the injected fetchSongs function without another public file.

test/fixtures/local_songs.dart is sample catalog data for existing tests, not production.

## Behavior

Firestore is read once on initialization, ordered by sortOrder. Retry reloads it.
Images support both bundled assets and HTTP(S) URLs through SongImage; existing error placeholders are preserved. Audio paths support both bundled assets and HTTP(S) URLs, including Supabase public Storage URLs. Remote audio needs network access; persistent audio download caching is not implemented.
Switch/selection, Premium checks, looping, pause/resume, seek/resume, stale-request
protection and error messages are preserved. Closing details cancels only its
listeners; shared playback continues. Disposing shared music releases the player.

## Dependency rule

Domain knows no Firebase, Flutter, GetX or just_audio. Data implements domain
contracts. Controllers depend on those contracts and injected access callbacks.
Concrete wiring belongs in music_dependencies.dart.
