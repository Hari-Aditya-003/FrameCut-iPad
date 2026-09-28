# FrameCut for iPad — Feature Set

FrameCut is an iPad-first media player with a precise, approachable trimming workspace. It is designed for the 8th-generation iPad and newer, in portrait, landscape, Split View, and with a keyboard or trackpad.

## Version 1 — included in this project

- Import video or audio from Files, iCloud Drive, external drives, and compatible document providers.
- Keep an in-app session library and quickly reopen imported items.
- Play, pause, jump backward/forward 10 seconds, drag the playhead, and restart playback.
- Adjust in-app volume with dedicated up/down buttons or a slider, mute/unmute, and select 0.5×, 1×, 1.5×, or 2× speed.
- Switch among Fit, Fill, and Stretch presentation modes, and open video in full screen.
- Use the system playback surface, including Picture in Picture and route/AirPlay controls when available.
- Trim with separate in/out handles, live timecodes, minimum-range protection, preview looping, and fine ±0.1-second nudges.
- Export the selected range at high quality and open the iPad share sheet to save or send it.
- Display progress and actionable errors for loading and export failures.
- Support VoiceOver labels, large touch targets, keyboard shortcuts, light/dark appearance, and responsive iPad layouts.

## Format support

The built-in AVFoundation engine supports Apple's native media formats and codecs, including typical MP4, MOV, M4V, MP3, M4A/AAC, WAV, and AIFF files. Actual playback depends on the codec inside a container.

MKV, AVI, WebM, FLAC, OGG, and other VLC-style formats are recognized, but need a third-party codec engine such as MobileVLCKit. The app separates playback behind a controller so that engine can be integrated without redesigning the library, controls, or editor. It is intentionally not downloaded into this offline starter project because of binary size, licensing, and App Store review considerations.

## Recommended next version

- MobileVLCKit playback adapter for expanded codec support.
- Subtitle selection and external SRT/VTT import.
- Audio-track selection, equalizer, and audio-only export.
- Persistent bookmarks and security-scoped file access across launches.
- Frame-thumbnail generation and frame-accurate GOP-aware re-encoding presets.
- Multi-clip queue, crop, rotate, and simple color adjustments.
