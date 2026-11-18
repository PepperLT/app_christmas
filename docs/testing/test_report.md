# Christmas Countdown - Test Report

## 1. Project Information

| Item | Details |
|---|---|
| Application | Christmas Countdown |
| Version | 1.0.0+1 |
| Android application ID | com.santa.christmascountdown |
| Test date | November 18, 2026 (Asia/Bangkok) |
| Environment | Windows, PowerShell, Flutter 3.38.5 stable, Dart 3.10.4 |
| Execution scope | Current working tree; host unit/widget tests with fake players, repositories and mock preferences |
| Device / release artifact | No physical-device or emulator session; no signed release artifact tested |
| Review changes | Only this report edited; no source, test cases, dependencies or backend configuration changed |

## 2. Test Summary

| Metric / command | Result | Status |
|---|---|---|
| Total tests | 65 per full-suite run | PASSED |
| Successful tests | 65 | PASSED |
| Failed tests | 0 | PASSED |
| Success rate | 100% | PASSED |
| `flutter analyze` | Exit 0; No issues found; 8.1 seconds reported | PASSED |
| `flutter test` | Exit 0; 65 passed, 0 failed; 21 seconds reported | PASSED |
| `flutter test --coverage` | Exit 0; 65 passed, 0 failed; 33 seconds reported | PASSED |
| Line coverage | 74.86%: 1,346 / 1,798 executable lines across 52 recorded files | PASSED |

Coverage was calculated from unique SF/DA records in the newly generated `coverage/lcov.info`. It describes instrumented Dart files, not all repository code, native SDKs or backend rules. No branch-coverage percentage or coverage acceptance threshold is claimed. The two full-suite runs execute the same 65 cases and are not counted as 130 distinct tests.

## 3. Functional Testing

Statuses below apply only to observed automated assertions. Real-device acceptance is not implied.

| Feature | Test Description | Status | Notes |
|---|---|---|---|
| Welcome | Initial app route renders Welcome and title | PASSED | `widget_test.dart`; real launch and Welcome tap-to-Countdown flow not independently tested |
| Countdown | Drawer share request order and screenshot content | PASSED | `countdown_share_test.dart`; exact Dec 25/26 and year rollover NOT RUN |
| Music | Selection, pause/resume, seeking, rapid input, failed load/retry, remote-source selection and disposal | PASSED | Music player, URL and detail tests use fakes; real codec/audio focus/stream availability NOT RUN |
| Advent Calendar | Date locks, duplicate claims, stars, year rollover, invalid content, retry and reward dialog layout | PASSED | Controller, Firestore mapper and dialog tests; live backend and device-date boundaries NOT RUN |
| Bubble Box | Merge rules, rescue, reset, invalid actions and deterministic stress | PASSED | 1,000 games; 19,010 merges; min 4, max 41, average 19.01; not an FPS benchmark |
| Wallpapers | Valid apply, persistence, invalid path fallback and small-landscape preview | PASSED | In-app Countdown backgrounds only; no system wallpaper setting |
| Settings | Shared music state and persisted snowfall/sound-effect preferences | PASSED | Mock preferences/fake audio; actual process restart and device storage durability NOT RUN |
| About | Open bundled Privacy Policy, read/scroll and navigate back | PASSED | `privacy_policy_test.dart`; no verified public policy URL |
| Share | Capture PNG, exclude menu and dispatch one injected share request | PASSED | Countdown and shared scaffold tests; actual recipient applications NOT RUN |
| Navigation | Initial route, settings/music state across routes and About/policy return | PASSED | Covered route interactions only; exhaustive back-stack and route lifecycle testing NOT RUN |

All local audio/image paths in `test/fixtures/local_songs.dart` currently exist. This static check does not verify decoding or production Firestore paths. Premium access defaults to unlocked, its menu is hidden and named route removed; retained Premium code is not a connected real payment implementation.

## 4. Non-functional Testing

| Area | Check | Status | Notes |
|---|---|---|---|
| Performance | Bubble Box logical stress; fake-player stale-request/disposal behavior | PASSED | Existing automated assertions succeeded |
| Performance | Timer, subscriptions and resource cleanup review | NOT VERIFIED | Countdown/Advent timers, Music/detail subscriptions and animation/player/image disposal are present; source review is not proof of leak-free device behavior |
| Performance | FPS, heap growth, CPU, battery, real playback latency and repeated navigation | NOT RUN | Profile-mode/device measurements required |
| Security | Deployed Firestore Rules and Supabase Storage Policies | NOT VERIFIED | No deployed policy evidence or production access available |
| Security | Release signing configuration | FAILED | Release Gradle selects debug signing; see REL-01 |
| Security | Permissions, client keys and transport | NOT VERIFIED | Main manifest declares INTERNET; client/publishable keys are present; loaders accept HTTP and HTTPS. Merged manifest, full secret history and live URL security were not audited |
| Local Storage | Snowfall, sound effects, wallpaper and Advent preferences/duplicate-claim behavior | PASSED | Mock persistence tests; stars derive from claimed days and calendar data |
| Local Storage | Music switch/selection restoration, OS backup and process-death recovery | NOT VERIFIED | Music values and Bubble Box board are currently memory-only; whether persistence is required needs developer confirmation |
| Network and Offline | Fake repository failures, malformed data, retry, late responses and audio failures | PASSED | No production writes or live service requests performed |
| Network and Offline | Real outage, slow network, timeouts, reconnect, TLS/codec and image-server failures | NOT RUN | Source lacks application deadlines for catalog/audio loading; see NET-01 |
| UI/UX | Reward dialog portrait/landscape, wallpaper landscape, snowfall touch behavior and policy navigation | PASSED | Widget-test assertions only |
| UI/UX | Physical-device layout, accessibility, large text, launcher presentation and manual release acceptance | NOT RUN | No confirmed manual PASSED evidence supplied for this run |

## 5. Known Issues

Static risks are identified as such; they are not fabricated production failures.

| ID | Issue | Severity | Recommendation |
|---|---|---|---|
| REL-01 | `android/app/build.gradle.kts:40`: release uses debug signing. | Critical release blocker | Configure approved upload signing and verify the signed AAB before submission. |
| NET-01 | `music_controller.dart:44,248`: repository fetch and audio load have no application timeout; a never-completing future can retain loading/busy state. Source-confirmed risk; not reproduced on a live network in this run. | High | Add bounded waits and safe retry/stale-response handling, with targeted tests, after approval. |
| INIT-01 | `lib/main.dart:18-23`: Firebase, Supabase and preferences initialize before runApp without startup error handling. Failure may prevent the UI from opening. | High potential risk | Introduce approved startup recovery and test initialization exceptions and pending requests. |
| SEC-01 | Production rules, policies, permissions and actual media hosts remain unverified. | High assurance gap | Audit deployed configuration read-only and validate access in emulator/staging. |
| LEG-01 | Public Privacy Policy URL remains pending; `docs/legal/asset_rights_register.csv` is absent in the current working tree and media permissions are not established. | High release blocker | Supply licensing evidence and publish the reviewed policy; resolve privacy-practice confirmations. |
| QA-01 | Current tests do not verify full startup, real calendar boundaries or actual platform playback/share behavior. | Medium coverage gap | Complete device/release acceptance tests and add approved focused coverage where needed. |

## 6. Conclusion

**Automated testing: PASSED.** Both complete runs finished with 65 successful tests and no failures; Flutter Analyze reported no issues. Current line coverage is 74.86% within the LCOV scope.

**Deployment readiness: NOT VERIFIED; not ready for production approval.** Resolve the signing and legal blockers, review loading/startup risks, verify backend security, and complete manual signed-release testing. No release artifact was built or deployed. No source fixes or test modifications were made during this review.
