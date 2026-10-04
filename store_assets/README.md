# Prismleaf Vale — Play listing package

The images here are artwork and listing assets, not gameplay screenshots. **Phone screenshots are pending** until an Android build can run on a device. Do not upload invented or composited gameplay as screenshots.

| File | Dimensions | Format | Status |
| --- | --- | --- | --- |
| `feature_graphic_1024x500.jpg` | 1024 × 500 | JPEG, no alpha | Created; review layout in Play Console |
| `play_icon_512.png` | 512 × 512 | 32-bit PNG | Created; review against Play icon mask |
| `phone_home_*.png` | Device native | PNG | Pending actual device capture |
| `phone_gameplay_*.png` | Device native | PNG | Pending actual device capture |
| `phone_levels_*.png` | Device native | PNG | Pending actual device capture after unlocking levels |
| `phone_completion_*.png` | Device native | PNG | Pending actual completed level |

Google's current [preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en) require a 1024 × 500 feature graphic, a 512 × 512 PNG listing icon at most 1024 KB, and at least two real screenshots. Capture phone screenshots from the built Android app after playing it, at native device resolution. Prefer a portrait device with at least 1080 × 1920 pixels. Check framing, legibility, and policy requirements before uploading.

Suggested capture order: home, trail with unlocked levels, live gameplay after the intro card, and a genuine success result. Use `adb shell screencap -p /sdcard/prismleaf.png` and `adb pull /sdcard/prismleaf.png store_assets/phone_gameplay_01.png` while the relevant screen is visible. Review each screenshot to confirm it matches the shipping app. Do not add captions that cover gameplay.

## Listing copy draft

**Short description:** Restore a glowing valley in an offline match-three journey

**Full description:**

Follow a trail through Prismleaf Vale, a quiet valley lit by every match. Swap colorful faceted leaves, collect each glade's objectives, and clear the board before your moves run out. Special pieces add a spark, while a fresh shuffle keeps the trail moving when swaps run dry.

Explore five glades with different board shapes and goals. Completed glades unlock the next stop, and your progress stays on your device. Claim daily glow, track your best scores, and unlock a Twilight backdrop. Turn sound effects on or off at any time. The game plays offline without an account; optional ads may appear on the trail map or offer extra moves after a loss.

**Relevant search terms for editorial review:** match three, offline puzzle, tile matching, colorful gems, casual puzzle, level progression.

## Release checklist

- Capture and inspect real Android screenshots for the screens above; verify Google Play's latest screenshot rules.
- Review icon, feature graphic, descriptions, and localization for each target market.
- Confirm original artwork and upstream code rights for commercial distribution.
- Configure private release signing; build and install a release variant on Android.
- Test gameplay, pause, sound setting, progress persistence, and lifecycle on physical devices.
- Complete Play Console data safety, content rating, privacy and target-audience declarations as applicable.
- Publish a reviewed privacy policy at a public URL and add it to Play Console. Start from `privacy_policy_draft.md` and fill the publisher details.
- Configure UMP privacy messages in AdMob, verify ad units, register test devices, and validate consent behavior in relevant regions.
- If children are in the target audience, review Families requirements and adapt ads and age handling before enabling production ads.
