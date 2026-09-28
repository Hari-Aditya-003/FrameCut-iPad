# FrameCut for iPad

FrameCut is an iPad-first SwiftUI media player and precision trimmer. It is configured as an iPad-only Xcode project with an iOS 18 deployment target, so it can run on an 8th-generation iPad using iPadOS 18 or later, including iPadOS 26.x.

## Included

- Import multiple video and audio files from Files, iCloud Drive, or an external drive.
- Session media library with video/audio identification and safe file access.
- Play, pause, seek, jump ±10 seconds, playback speed, mute, volume slider, and dedicated volume up/down controls.
- AirPlay/audio-route picker, Picture in Picture support, full screen, and Fit/Fill/Stretch video modes.
- Precise trim start/end controls, ±0.1-second nudging, trim-loop preview, reset, duration display, and minimum-range protection.
- High-quality MP4/MOV/M4A export and the iPad share sheet.
- Portrait, upside-down portrait, and both landscape orientations; responsive layouts for Split View.
- Keyboard shortcuts: Command-O to import, Space to play/pause, Left/Right Arrow to seek, and M to mute.
- VoiceOver labels and large iPad-friendly controls.
- Swift Testing coverage for trim math, timecodes, and media-format classification.

See `FEATURES.md` for the complete feature and format plan.

## Open and run in Xcode

1. Open `FrameCut.xcodeproj` in Xcode 27 or newer.
2. Select the **FrameCut** project, then the **FrameCut** target.
3. Under **Signing & Capabilities**, choose your Apple Developer Team. If Xcode reports that the bundle ID is already used, change `com.framecut.ipad` to a unique identifier such as `com.yourname.framecut`.
4. Connect the iPad by USB or enable wireless debugging. Trust the Mac and enable Developer Mode on the iPad if prompted.
5. Select the iPad as the run destination and press **Run**.

No paid Apple Developer account is required for personal on-device testing, although free signing installations expire and need to be rebuilt periodically. App Store distribution requires a paid account and its normal signing/review process.

## Use the app

1. Tap **Choose from Files** or the plus button.
2. Select one or more supported video/audio files.
3. Use the player controls, then drag the orange trim handles or use the 0.1-second nudge buttons.
4. Tap **Preview Trim** to loop the chosen range.
5. Tap **Export Trim**, then **Share Export** to save it to Files, Photos, or another app.

## Media format note

Apple's AVFoundation engine directly handles common MP4, MOV, M4V, MP3, M4A/AAC, WAV, AIFF, and CAF media when the codec inside the file is supported. A file extension alone cannot guarantee playback.

VLC-style containers and codecs such as MKV, AVI, WebM, FLV, WMV, TS/MTS/M2TS, FLAC, OGG, Opus, and WMA are recognized and reported as requiring a codec pack. True VLC-level format coverage requires integrating a compatible engine such as MobileVLCKit; that binary dependency is intentionally not bundled because it materially increases app size and introduces licensing and App Store decisions.

## Privacy

FrameCut processes imported media locally. This starter project contains no analytics, accounts, advertising, cloud upload, or network service.

