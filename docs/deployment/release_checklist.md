# Release Checklist — Christmas Countdown

- Target version: 1.0.0+1 (proposed)
- Platform: Android / Google Play
- Release date: TBD
- Status: Pending verification; not approved for release
- Evidence: [Test report](../testing/test_report.md) and [Legal publication status](legal_publication.md)
- Earlier automated checks passed in this session; every checkbox below is a final-release action and remains unchecked until verified for the chosen release candidate.

## 1. Source code and configuration

- [ ] Confirm release branch and commit all intended changes.
- [ ] Confirm application name and launcher icon on a device.
- [ ] Confirm application ID (`com.santa.christmascountdown`, verify actual value).
- [ ] Confirm version name and build number in pubspec.yaml.
- [ ] Verify current Google Play target API and applicable Android compatibility requirements against the built artifact, including applicable native-library page-size requirements.
- [ ] Check release manifest permissions, including INTERNET.
- [ ] Verify the hidden Premium menu, removed named route and default unlocked access on the final build; conditional dialogs remain in source. Confirm no real payment flow is advertised.
- [ ] Remove debug-only date overrides and test content.
- [ ] Verify no private keys, passwords or service-role keys are bundled or committed.

## 2. Firebase and Supabase

- [ ] Verify Firebase configuration matches the release application ID.
- [ ] Verify Firestore Security Rules prevent unauthorized modifications.
- [ ] Verify Supabase Storage policies prevent unauthorized uploads, edits and deletes.
- [ ] Verify Firestore metadata, local/remote audio and cover images, bundled Countdown backgrounds and Advent content in release mode.
- [ ] Inventory actual production media URLs; verify host ownership, availability and licensing rather than assuming every URL is Supabase.
- [ ] Review Firebase/Supabase logging, retention, processing regions and any additional production services.
- [ ] Verify production URLs, HTTPS and error handling.
- [ ] Review quotas, bandwidth and service availability.

## 3. Testing

- [ ] Run `flutter analyze` and resolve release-blocking findings.
- [ ] Run `flutter test` and resolve failures.
- [ ] Test Countdown and Christmas date rollover.
- [ ] Test Music playback, pause and track changes.
- [ ] Test Advent date locks, duplicate claims and yearly progress.
- [ ] Test Bubble Box merge rules and game reset.
- [ ] Test in-app Countdown backgrounds, snowfall, sound effects and yearly Advent progress after restart. Verify music selection/switch and Bubble Box board reset as currently implemented.
- [ ] Verify no system wallpaper change is advertised or expected.
- [ ] Test About > Privacy Policy offline, scrolling, readability and navigation.
- [ ] Test small screens, landscape, large text, app background/resume and interruption of music playback.
- [ ] Test screenshot sharing and offline/network-error behavior.
- [ ] Test on a physical Android device and a release build.
- [ ] Record commands, SDK versions, date, commit/build ID, devices and actual results in [Test report](../testing/test_report.md). Keep unexecuted tests NOT RUN.
- [ ] Resolve release-blocking bugs; passing unit/widget tests is not physical-device or production validation.

## 4. Store listing and policies

- [ ] Verify store icon PNG, 512 x 512 px, within size limit.
- [ ] Verify feature graphic, 1024 x 500 px.
- [ ] Verify screenshots accurately represent the release build.
- [ ] Finalize app name, short and full descriptions, category and support email.
- [ ] Confirm the support email is controlled and monitored, and confirm who accesses correspondence, its retention/deletion period and the privacy-request process.
- [ ] Confirm actual SDK/provider logging, data categories, retention and processing locations; resolve all draft statements in [Privacy Policy](../legal/privacy_policy.md).
- [ ] Confirm target age groups, whether children are included, and applicable audience/privacy requirements.
- [ ] Publish the reviewed Privacy Policy at an accessible public URL (PENDING); verify it without login, regional restriction or a PDF download.
- [ ] Enter the verified policy URL in Play Console; separately verify access to the policy from the app. A bundled policy exists, but no public URL link is implemented.
- [ ] Keep public and bundled policy versions consistent; request any app changes separately because this review is docs-only.
- [ ] Complete [asset rights register](../legal/asset_rights_register.csv) using evidence for compositions, arrangements, recordings, effects, images, icon and promotional artwork. Preserve UNVERIFIED until evidence is checked.
- [ ] Add rights evidence for live remote content and Advent text; do not assume hosting or traditional titles grant permission.
- [ ] Review and preserve full applicable package, font and native SDK notices and provide required user access; [licenses.md](../legal/licenses.md) is only a summary.
- [ ] Finalize [Terms of Service](../legal/terms_of_service.md) and decide how users can access them; remove publication-draft notes only after confirmation.
- [ ] Review data collection by the app and third-party SDKs for Data Safety.
- [ ] Finalize release notes.

## 5. Signing and release build

- [ ] Create or locate the upload keystore and securely back it up.
- [ ] Configure release signing in Gradle.
- [ ] Exclude keystore and signing credentials from Git.
- [ ] Determine whether cleaning build outputs is needed; a clean command itself is not release validation.
- [ ] Run `flutter pub get`.
- [ ] Run `flutter build appbundle --release`.
- [ ] Verify `build/app/outputs/bundle/release/app-release.aab` exists and is correctly signed.

## 6. Google Play Console

- [ ] Complete developer account registration and required verification.
- [ ] Create the app and configure Play App Signing.
- [ ] Complete store listing and upload graphic assets.
- [ ] Complete Data Safety, App Access, Ads, Content Rating, Target Audience and other applicable declarations.
- [ ] Configure pricing and distribution countries.
- [ ] Upload the signed AAB and release notes to Internal testing.
- [ ] Review pre-launch report and fix release-blocking issues.
- [ ] Install through a Play testing track to validate the Play-delivered app, content access and signing-related configuration.
- [ ] Complete Closed testing and apply for Production access if required by the account.
- [ ] Create Production release and submit for review.
- [ ] Resolve any review findings and publish after approval.

## 7. Post-release

- [ ] Verify the Google Play listing and install the published app.
- [ ] Monitor Android vitals, user feedback and backend usage.
- [ ] Record release date and version; tag the released commit in Git.

## Release sign-off

- Tested by: TBD
- Release owner: TBD
- Release commit: TBD
- Outstanding issues: TBD
- Final decision: NOT READY — licensing evidence, public privacy URL, privacy confirmations, release signing and manual release verification remain outstanding.

All unchecked items must be verified or explicitly marked not applicable. This checklist is an internal project document, not a substitute for Play Console requirements.
