# Release Notes — Christmas Countdown

## Version 1.0.0 (Build 1)

- Platform: Android
- Distribution: Google Play
- Release date: TBD
- Status: Draft — automated results recorded; manual release testing and approval pending
- Release type: Initial release

### Features

- Christmas Countdown: days, hours, minutes and seconds until Christmas.
- Christmas Music: browse and play festive music.
- Advent Calendar: open daily gifts from December 1 to 25 and collect stars.
- Bubble Box: merge matching Christmas items.
- Wallpapers: personalize the in-app Countdown background; no system wallpaper setting.
- Settings: customize music, snowfall and sound effects.
- Share: share Christmas countdown screenshots.

### Technical overview

- Flutter and GetX.
- Firebase Cloud Firestore for remote content metadata.
- Music playback accepts bundled asset paths and HTTP(S) URLs; song artwork accepts asset paths and remote URLs.
- Supabase is initialized, but actual media hosts depend on the Firestore song data. Live production media locations have not been audited.
- Wallpaper choices are bundled images, not remote system-wallpaper downloads.
- SharedPreferences for local preferences and progress.

### Release scope and limitations

- Premium is hidden from the menu and its named route is removed. Access defaults to unlocked; conditional Premium dialogs and module code remain. No real store payment integration is connected.
- Remote media and uncached content metadata require a connection. Bundled audio support does not guarantee an offline catalog: the song list is read from Firestore. No persistent audio-download feature is implemented.
- Automated checks: an earlier run in this session reported 65 tests passed and no analyzer issues; these checks were not rerun during this docs-only review.
- Manual signed-release, physical-device and production-service tests remain NOT RUN in the available evidence.
- Evidence, environment, limitations and blockers: [Test report](../testing/test_report.md).

### Google Play release notes (en-US)

Welcome to Christmas Countdown! Count down to Christmas, enjoy festive music, open daily Advent gifts, play Bubble Box and customize your in-app Countdown background.

### Google Play release notes (vi-VN)

Chào mừng bạn đến với Christmas Countdown! Cùng đếm ngược Giáng sinh, thưởng thức âm nhạc, mở quà Advent mỗi ngày, chơi Bubble Box và tùy chỉnh nền Countdown trong ứng dụng.

---

For each future release, add a new version section above this one with the release date, new features, improvements, bug fixes and known issues.
