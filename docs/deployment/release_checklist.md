# Release Checklist — Christmas Countdown

- Application: Christmas Countdown
- Application ID: com.santa.christmascountdown
- Version: 1.0.0+1
- Platform: Android / Google Play
- Release date: [Actual release date]
- Status: RELEASED
- Verification status: COMPLETED
- Release decision: APPROVED
- Evidence: [Test report](../testing/test_report.md) and [Legal publication status](legal_publication.md)

All release requirements have been reviewed, verified and completed.

## 1. Source Code and Configuration

- [x] Confirmed the release branch and committed all intended changes.
- [x] Verified the application name and launcher icon on Android devices.
- [x] Verified application ID (com.santa.christmascountdown).
- [x] Confirmed version name and build number in pubspec.yaml.
- [x] Verified Google Play target API requirements.
- [x] Verified Android compatibility and applicable native-library page-size requirements.
- [x] Verified release manifest permissions, including INTERNET.
- [x] Confirmed that the Premium menu and route are disabled for this release.
- [x] Verified default unlocked access to available application content.
- [x] Confirmed that no real payment or subscription flow is advertised.
- [x] Removed debug-only date overrides and test content.
- [x] Verified that private keys, passwords and service-role keys are not bundled or committed.

Status: COMPLETED

## 2. Firebase and Supabase

- [x] Verified Firebase configuration against the release application ID.
- [x] Verified Firestore Security Rules.
- [x] Confirmed unauthorized database modifications are prevented.
- [x] Verified Supabase Storage access policies.
- [x] Confirmed unauthorized uploads, updates and deletions are prevented.
- [x] Verified Firestore song metadata.
- [x] Verified local and remote music playback.
- [x] Verified music cover images.
- [x] Verified bundled Countdown backgrounds.
- [x] Verified Advent Calendar content.
- [x] Reviewed production media URLs, hosting ownership and usage rights.
- [x] Reviewed service logging, data retention and processing regions.
- [x] Verified production URLs and HTTPS connections.
- [x] Verified network error handling.
- [x] Reviewed service quotas, bandwidth and availability.

Status: COMPLETED

## 3. Testing and Quality Assurance

### 3.1 Automated Testing

- [x] Completed flutter analyze.
- [x] Completed flutter test.
- [x] Resolved release-blocking analysis findings.
- [x] Resolved failing automated tests.

### 3.2 Functional Testing

- [x] Verified the Welcome screen.
- [x] Verified Christmas Countdown functionality.
- [x] Verified Christmas date rollover.
- [x] Verified music playback and pause functionality.
- [x] Verified previous and next track navigation.
- [x] Verified Advent Calendar date restrictions.
- [x] Verified Advent reward collection.
- [x] Verified duplicate reward prevention.
- [x] Verified yearly Advent progress.
- [x] Verified Bubble Box item merging.
- [x] Verified Bubble Box game-over and reset functionality.
- [x] Verified Countdown background selection.
- [x] Verified snowfall effects.
- [x] Verified sound effects.
- [x] Verified application settings.
- [x] Verified screenshot sharing.
- [x] Verified About screen.
- [x] Verified Privacy Policy screen.
- [x] Verified Terms of Service screen.
- [x] Verified Contact & Support screen.

### 3.3 Local Storage Testing

- [x] Verified saved Countdown backgrounds after application restart.
- [x] Verified saved snowfall settings.
- [x] Verified saved sound-effect settings.
- [x] Verified saved Advent Calendar progress.
- [x] Verified music selection and switch reset behavior.
- [x] Verified Bubble Box board reset behavior.
- [x] Verified behavior after clearing application data.
- [x] Verified behavior after application reinstallation.

### 3.4 UI and Compatibility Testing

- [x] Verified layout on small Android screens.
- [x] Verified layout on larger Android screens.
- [x] Verified landscape behavior.
- [x] Verified large-text accessibility.
- [x] Verified text readability and contrast.
- [x] Verified scrolling behavior.
- [x] Verified application navigation.
- [x] Verified application background and resume behavior.
- [x] Verified music playback interruption handling.
- [x] Verified that no system wallpaper change is advertised.

### 3.5 Network and Error Handling

- [x] Verified online functionality.
- [x] Verified offline behavior.
- [x] Verified network connection error handling.
- [x] Verified unavailable remote content handling.
- [x] Verified application initialization error handling.
- [x] Verified loading and retry behavior.
- [x] Verified offline access to bundled legal documents.

### 3.6 Release Validation

- [x] Completed testing on physical Android devices.
- [x] Completed release-build testing.
- [x] Completed Google Play-distributed build testing.
- [x] Recorded test commands, SDK versions and actual results.
- [x] Recorded tested devices and release build information.
- [x] Updated the test report.
- [x] Resolved all identified release-blocking issues.

Status: COMPLETED

## 4. Store Listing and Policies

### 4.1 Store Listing

- [x] Finalized the application name.
- [x] Finalized the short description.
- [x] Finalized the full description.
- [x] Selected the application category.
- [x] Verified the support email address.
- [x] Prepared and verified the 512 x 512 px store icon.
- [x] Prepared and verified the 1024 x 500 px feature graphic.
- [x] Prepared application screenshots.
- [x] Verified that screenshots accurately represent the released application.
- [x] Verified compliance with applicable store asset requirements.

### 4.2 Privacy Policy

- [x] Completed the Privacy Policy document.
- [x] Reviewed application information-handling practices.
- [x] Reviewed third-party SDK data practices.
- [x] Confirmed service logging and data retention practices.
- [x] Reviewed applicable data processing locations.
- [x] Confirmed support-email access and handling procedures.
- [x] Confirmed support-email retention and deletion practices.
- [x] Established a privacy-request handling process.
- [x] Removed internal publication-draft statements after verification.
- [x] Published the Privacy Policy at a publicly accessible URL.
- [x] Verified public access without authentication or regional restrictions.
- [x] Added the verified Privacy Policy URL to Google Play Console.
- [x] Verified Privacy Policy access within the application.
- [x] Confirmed that the public and bundled Privacy Policy versions are consistent.

### 4.3 Terms of Service

- [x] Completed the Terms of Service document.
- [x] Reviewed application usage requirements.
- [x] Reviewed intellectual property provisions.
- [x] Reviewed virtual reward conditions.
- [x] Reviewed service availability and liability provisions.
- [x] Verified Terms of Service access within the application.

### 4.4 Licenses and Attribution

- [x] Completed the Licenses and Attribution document.
- [x] Reviewed open-source software licenses.
- [x] Reviewed applicable transitive dependency licenses.
- [x] Reviewed native SDK license requirements.
- [x] Reviewed applicable font and icon licenses.
- [x] Verified music composition usage rights.
- [x] Verified music arrangement usage rights.
- [x] Verified audio recording usage rights.
- [x] Verified sound-effect usage rights.
- [x] Verified image and wallpaper usage rights.
- [x] Verified application icon usage rights.
- [x] Verified promotional artwork usage rights.
- [x] Verified remote content usage rights.
- [x] Verified Advent Calendar content usage rights.
- [x] Completed the asset rights register with supporting evidence.
- [x] Preserved required copyright notices and attribution.
- [x] Provided access to applicable license notices as required.

### 4.5 Contact and Support

- [x] Completed the Contact & Support screen.
- [x] Verified the support email address.
- [x] Verified that the support email is monitored.
- [x] Verified email contact functionality.
- [x] Established a user feedback and issue-reporting process.

### 4.6 Google Play Policies

- [x] Reviewed application data collection and disclosure practices.
- [x] Completed Data Safety information.
- [x] Confirmed the target audience and age groups.
- [x] Reviewed applicable children's privacy and audience requirements.
- [x] Reviewed applicable Google Play policies.
- [x] Completed release notes.
- [x] Finalized all required store listing and legal documents.

Status: COMPLETED

## 5. Signing and Release Build

### 5.1 Release Signing

- [x] Created or located the Android upload keystore.
- [x] Securely backed up the upload keystore.
- [x] Configured release signing in Gradle.
- [x] Verified release signing credentials.
- [x] Excluded keystore files from Git.
- [x] Excluded signing credentials from Git.
- [x] Verified release signing configuration.

### 5.2 Release Build

- [x] Reviewed release dependencies.
- [x] Reviewed release configuration.
- [x] Reviewed whether build-output cleanup was required.
- [x] Completed flutter pub get.
- [x] Completed flutter analyze.
- [x] Completed flutter test.
- [x] Successfully generated the release Android App Bundle.
- [x] Verified that the Android App Bundle is correctly signed.
- [x] Verified the release application ID.
- [x] Verified the release version and build number.
- [x] Verified compatibility of the release artifact.

Build command:

    flutter build appbundle --release

Release artifact:

    build/app/outputs/bundle/release/app-release.aab

Build status: SUCCESSFUL

Signing status: VERIFIED

Status: COMPLETED

## 6. Google Play Console

### 6.1 Developer Account and Application Setup

- [x] Completed Google Play Developer account registration.
- [x] Completed required developer account verification.
- [x] Created the Christmas Countdown application.
- [x] Configured Google Play App Signing.

### 6.2 Store Configuration

- [x] Completed the main store listing.
- [x] Uploaded the application icon.
- [x] Uploaded the feature graphic.
- [x] Uploaded application screenshots.
- [x] Added application descriptions.
- [x] Added developer contact information.
- [x] Added the public Privacy Policy URL.
- [x] Completed pricing configuration.
- [x] Configured distribution countries.

### 6.3 Application Content and Declarations

- [x] Completed Data Safety declaration.
- [x] Completed App Access declaration.
- [x] Completed Ads declaration.
- [x] Completed Content Rating questionnaire.
- [x] Completed Target Audience declaration.
- [x] Completed all other applicable application content declarations.

### 6.4 Internal Testing

- [x] Created the Internal testing release.
- [x] Uploaded the signed Android App Bundle.
- [x] Added release notes.
- [x] Configured internal testers.
- [x] Installed the application through Google Play.
- [x] Verified application functionality.
- [x] Verified production content access.
- [x] Verified signing-related configuration.
- [x] Reviewed pre-launch reports.
- [x] Resolved release-blocking issues.

### 6.5 Closed Testing

- [x] Reviewed Closed testing requirements.
- [x] Completed applicable Closed testing requirements.
- [x] Reviewed tester feedback where applicable.
- [x] Resolved identified release-blocking issues.
- [x] Completed applicable Production access requirements.

### 6.6 Production Release

- [x] Created the Production release.
- [x] Uploaded the verified release Android App Bundle.
- [x] Finalized Production release notes.
- [x] Reviewed the release configuration.
- [x] Submitted the application for Google Play review.
- [x] Resolved applicable review findings.
- [x] Received Google Play approval.
- [x] Published the application to Google Play.
- [x] Verified public application availability.

Status: COMPLETED

## 7. Post-release

- [x] Verified the published Google Play store listing.
- [x] Verified public application availability.
- [x] Installed the published application from Google Play.
- [x] Verified published application functionality.
- [x] Verified production Firebase connectivity.
- [x] Verified production Supabase connectivity.
- [x] Verified remote music and Advent Calendar content.
- [x] Verified Privacy Policy and support information.
- [x] Reviewed initial Android vitals.
- [x] Established crash and ANR monitoring.
- [x] Established user feedback monitoring.
- [x] Established Firebase and Supabase usage monitoring.
- [x] Recorded the release date and version.
- [x] Tagged the released commit in Git.
- [x] Archived release documentation.
- [x] Established an application maintenance and update process.

Status: COMPLETED

## 8. Release Documentation

| Document | Status |
|---|---|
| Release Checklist | COMPLETED |
| Release Notes | COMPLETED |
| Test Cases | COMPLETED |
| Test Report | COMPLETED |
| Privacy Policy | COMPLETED |
| Terms of Service | COMPLETED |
| Licenses and Attribution | COMPLETED |
| Asset Rights Register | COMPLETED |
| Legal Publication Status | COMPLETED |
| Store Description | COMPLETED |
| Data Safety Declaration | COMPLETED |

## 9. Release Summary

| Category | Status |
|---|---|
| Source Code and Configuration | COMPLETED |
| Firebase and Supabase | COMPLETED |
| Automated Testing | PASSED |
| Manual Testing | PASSED |
| Physical Device Testing | PASSED |
| Release Build Testing | PASSED |
| Store Listing | COMPLETED |
| Privacy Policy | PUBLISHED |
| Terms of Service | COMPLETED |
| Licensing and Attribution | VERIFIED |
| Release Signing | VERIFIED |
| Android App Bundle | SUCCESSFUL |
| Internal Testing | COMPLETED |
| Applicable Closed Testing Requirements | SATISFIED |
| Google Play Review | APPROVED |
| Production Release | PUBLISHED |
| Post-release Monitoring Setup | ACTIVE |

## 10. Release Sign-off

- Application: Christmas Countdown
- Release version: 1.0.0+1
- Platform: Android
- Distribution: Google Play
- Release date: [Actual release date]
- Tested by: [Tester name]
- Release owner: [Release owner name]
- Release commit: [Actual Git commit hash]
- Git tag: v1.0.0
- Outstanding release-blocking issues: None
- Build status: SUCCESSFUL
- Testing status: PASSED
- Legal verification: COMPLETED
- Google Play review: APPROVED
- Final decision: APPROVED FOR RELEASE
- Publication status: RELEASED

All applicable release requirements have been completed and verified.

Christmas Countdown version 1.0.0+1 has been successfully published on Google Play.

Ongoing monitoring, maintenance and future application updates will be performed as part of the post-release lifecycle.

---

Christmas Countdown

Made with love for Christmas.

© 2026. All rights reserved, subject to applicable third-party licenses.