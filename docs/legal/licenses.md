# Licenses and Attribution

**Application:** Christmas Countdown  
**Android package:** `com.santa.christmascountdown`  
**Version reviewed:** `1.0.0+1`  
**Last updated:** November 18, 2026

## 1. Scope

This document summarizes software licenses and content attribution for this project.
It is based on the repository, resolved packages and their installed license files.
It does not grant rights to application code, branding or media.

## 2. Open-source software

| Component | License summary | Purpose |
|---|---|---|
| Flutter | BSD-style | Application framework and Material UI |
| cupertino_icons | MIT | Declared Cupertino icon dependency |
| get | MIT | State management, dependency injection and navigation |
| just_audio | MIT | Music and sound-effect playback |
| share_plus | BSD-style | Sharing generated images |
| shared_preferences | BSD-style | Local preferences and Advent progress |
| firebase_core | BSD-style | Firebase initialization |
| cloud_firestore | BSD-style | Reading song and Advent content |
| firebase_storage | BSD-style | Declared Firebase Storage dependency |
| supabase_flutter | MIT | Supabase client initialization |

These summaries do not replace the original license and copyright notices.
Transitive dependencies and native SDKs retain their own applicable licenses.
Preserve the notices required by the components included in the release build.

## 3. Development tools

- `flutter_launcher_icons` (MIT): generates launcher icons from the configured image.
- `flutter_lints` (BSD-style): provides development lint rules.
- `flutter_test`: Flutter SDK testing tools; see the SDK license and notices.

Development dependencies are listed for traceability, not as shipped runtime code.

## 4. Bundled music and sound effects

The repository contains these recordings under `assets/audio/`:

- `Bethlehem.mp3`
- `deck_the_halls.mp3`
- `jingle_bells.mp3`
- `slient_night.mp3` (filename as stored in this project)
- `we_wish_you.mp3`
- `what_child_is_this.mp3`

Sound effects under `assets/effects/` are `merge_pop.wav`,
`reward_bell.wav` and `rescue_sparkle.wav`.
Their creators, sources and usage permissions are not documented in the repository.
A traditional song title does not establish rights to a particular recording.

## 5. Images, wallpapers and icons

UI artwork is stored in `assets/images/`, including music artwork and decorations.
Ten wallpapers are stored in `assets/images/wallpapers/`.
The launcher source is `assets/icons/app_icon_1024.png`.
Store icons, screenshots and promotional artwork are under `docs/store_listing/`.
Asset-specific evidence is tracked in [asset_rights_register.csv](asset_rights_register.csv); entries remain unverified.
Do not assume these resources are public domain or freely redistributable.
No custom font files are declared; Flutter Material icons are enabled.

## 6. Remote content and release notices

Song metadata comes from Firestore `songs`; artwork and audio can use remote URLs.
Advent text comes from `advent_calendars/{year}/days`; live content was not audited.
Firebase or Supabase hosting does not itself grant rights to hosted content.
Before release, document each media creator, source, permission and required credit.
Check native SDK and final-build notices; this summary is not a complete notice bundle.
This Markdown file is not automatically displayed or bundled by the application.

## 7. Contact

Email: thaivku@gmail.com
