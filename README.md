# Prismleaf Vale

Prismleaf Vale is an offline Android match-three puzzle game. Swap faceted leaves to gather each glade's objectives before the move limit. Five glades have different board shapes and goals; completed glades unlock the next stop on the trail.

## Development

- Flutter 3.47 or newer and Dart 3.13 or newer
- Android SDK, compatible JDK, and an attached Android device or configured emulator for Android builds
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

The application ID is `com.jackreachermishra.prismleafvale`. Levels, best scores, daily rewards, glow, sound, and vibration preferences are stored locally with `shared_preferences`. The game needs no account or backend and remains playable without a network. It has optional AdMob banner and rewarded ads; there is no background music.

## Ads and consent

The official `google_mobile_ads` plugin is used for Android. The App ID is set with `com.google.android.gms.ads.APPLICATION_ID` in the main manifest; Gradle supplies Google's sample App ID for debug and profile builds and `ca-app-pub-4138113569115613~5280989015` for release. The banner and rewarded ad units are in [`lib/ads/ad_config.dart`](lib/ads/ad_config.dart).

Debug and profile builds always use Google's sample ad units. Release builds make **no ad requests by default**. To opt into live ad requests in a release build, use `--dart-define=ENABLE_PRODUCTION_ADS=true`. Never use that flag for local ad testing or click live ads. To register a physical test device, use `--dart-define=ADS_TEST_DEVICE_ID=HASH_FROM_LOGCAT` with a debug build; the sample ad units do not require a test device. For UMP geography testing, pass `--dart-define=UMP_TEST_DEVICE_ID=HASH_FROM_UMP_LOGCAT` in a debug build. That enables the EEA debug geography for that registered test device. These debug device IDs are ignored in release builds.

At launch, UMP refreshes consent information and displays a form if required. Ads initialize and load only if `canRequestAds()` returns true. The Settings sheet shows **Privacy options** when UMP requires an entry point. Configure the appropriate privacy messages in the AdMob console before enabling live ads. The in-app Privacy & data screen summarizes local storage and ads. A public privacy policy URL and Play Data safety answers still need publisher review; see [`store_assets/privacy_policy_draft.md`](store_assets/privacy_policy_draft.md). SDK initialization or consent does not guarantee ad fill.

## Android release

The release variant is no longer signed with debug keys. Create a private upload keystore and copy [`android/key.properties.example`](android/key.properties.example) to `android/key.properties`, then fill in the real values and keep both the keystore and properties private. Without signing credentials, a bundle is not upload ready. Confirm that `com.jackreachermishra.prismleafvale` is an identifier you control and that the AdMob App ID belongs to this app.

1. Install the Android SDK and JDK; run `flutter doctor` and `flutter devices`.
2. Run `flutter pub get`, `flutter analyze`, and `flutter test`.
3. Run `flutter build apk --debug` and test the app and Google sample ads on a device or emulator.
4. Complete the publisher and audience decisions in [`store_assets/README.md`](store_assets/README.md), configure UMP messages, add the public privacy policy URL, and capture real screenshots.
5. With signing configured, run `flutter build appbundle --release --dart-define=ENABLE_PRODUCTION_ADS=true` only when live ads are intended. Test the signed bundle and verify the merged manifest and ad behavior on a registered test device before uploading.
6. Upload the AAB through Google Play Console for **internal testing**, then **closed testing**, then a **staged production rollout** after review. Uploading and publishing are manual steps.

## Artwork and audio

The valley illustration and leaf icon were generated for this project. Gameplay pieces and the adaptive icon foreground are drawn by project code. The eight short effects are synthesized by [`tool/generate_sfx.ps1`](tool/generate_sfx.ps1). The former example artwork, third-party credited bomb images, and unused Unity sound-source folder were removed. Store listing drafts and asset status are in [`store_assets/README.md`](store_assets/README.md).

The match-three engine began from the Flutter Candy Crush example by Didier Boelens. This repository retains that code lineage while replacing its presentation. Review any upstream code license and the generated artwork before commercial release.
