# FrameCut: build, install, and distribute

FrameCut is a native iPad application. It is deployed through Xcode signing and Apple distribution. The repository does not contain an App Store release, signing credentials, or an automatically generated IPA.

## Build prerequisites

- A Mac with Xcode supporting the repository's Swift 6 code and iPadOS 18.0 minimum target.
- The shared `FrameCut` scheme in `FrameCut.xcodeproj`.
- A compatible iPad simulator or physical iPad.
- Your own Apple signing team for installation on a physical device.

The README recommends Xcode 27 or newer. Historical test evidence is recorded in [VERIFICATION.md](../VERIFICATION.md); rerun checks for the source commit you intend to distribute.

## Clone and inspect destinations

```bash
git clone https://github.com/Hari-Aditya-003/FrameCut-iPad.git
cd FrameCut-iPad
xcodebuild -list -project FrameCut.xcodeproj
xcodebuild -showdestinations -project FrameCut.xcodeproj -scheme FrameCut
```

Use an installed iPad simulator from the destination list:

```bash
xcodebuild test \
  -project FrameCut.xcodeproj \
  -scheme FrameCut \
  -destination 'platform=iOS Simulator,name=iPad (A16)'
```

Replace the simulator name if necessary. For an unsigned build check targeting physical hardware:

```bash
xcodebuild build \
  -project FrameCut.xcodeproj \
  -scheme FrameCut \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO
```

An unsigned build cannot be installed on a normal iPad.

## Install for personal testing

Open the project in Xcode, add your Apple Account, and select your own team under **FrameCut > Signing & Capabilities**. Keep automatic signing enabled. Change `com.framecut.ipad` to a bundle identifier you control if required.

Connect and trust the iPad, enable Developer Mode, choose it as the run destination, and run the app. Detailed device preparation and troubleshooting are in the [README](../README.md#install-on-a-physical-ipad).

Do not commit signing certificates, private keys, provisioning profiles, or account credentials. The shared project deliberately has an empty development-team setting.

## TestFlight and App Store distribution

1. Configure a paid Apple Developer team and an App Store Connect app record matching your bundle identifier.
2. Set the intended version and a new build number in the application target.
3. Run tests and verify import, playback, trimming, export, and sharing on a real iPad.
4. Select a generic iOS device destination and choose **Product > Archive**.
5. In Organizer, validate the archive and choose **Distribute App > App Store Connect > Upload**.
6. Wait for processing, select the build, and configure TestFlight testers or submit the App Store version.
7. Complete the required listing, screenshots, privacy information, and release settings.

Distribution requires the owner's Apple account and signing assets. A successful source build alone does not mean the app is published.

## Release checklist

- Test iPadOS 18 compatibility and the supported orientations.
- Exercise Files/iCloud imports and security-scoped access on a real device.
- Export short and long video/audio selections and open the resulting files.
- Check background playback, AirPlay, and Picture in Picture on supported hardware.
- Verify low-storage and unsupported-codec messages.
- Confirm privacy answers match the exact build and any dependencies you add.

Expanded VLC-style codecs are recognized but are not decoded by the current app. Do not advertise that support as shipped.

## Recovery and follow-up releases

Retain the source SHA, Xcode archive, symbols, and build number for each upload. Correct a faulty release in a new build and distribute it through the same Apple channel; do not assume a Git revert rolls back an already installed app. For personal builds, check out the intended source and install it again using Xcode.
