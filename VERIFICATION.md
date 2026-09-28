# FrameCut verification

Verified on September 28, 2026 with Xcode 27.0.

## Automated checks

- Debug simulator build-for-testing: passed.
- Full Swift Testing suite on iPad Pro 13-inch (M5), iPadOS 26.5 simulator: passed.
- Test definitions: 11 passed, 0 failed, 0 skipped.
- Parameterized test executions: 17 passed.
- Xcode static analysis in Release configuration: passed with no reported analyzer issues.
- Unsigned Release build for a generic physical iPad/iPhoneOS destination: passed.
- Produced Info.plist confirms iPad-only device family, iOS 18.0 minimum, and all four iPad orientations.

## Manual smoke check

- Installed and launched the Debug build in the iPadOS 26.5 simulator.
- Confirmed the two-column iPad layout, dark appearance, import actions, empty media state, and format guidance render correctly.

## Device-signing step still required

Xcode must sign the app with the owner's Apple ID/Developer Team before installing it on a physical iPad. This cannot be preconfigured safely in a shared project. Follow `README.md` under **Open and run in Xcode**.

