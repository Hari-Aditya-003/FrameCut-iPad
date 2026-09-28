import Foundation
import Testing
@testable import FrameCut

@Suite("Media format classification")
struct MediaFormatSupportTests {
    @Test("Native video and audio formats are recognized", arguments: [
        ("sample.MP4", MediaKind.video),
        ("recording.mov", MediaKind.video),
        ("song.MP3", MediaKind.audio),
        ("voice.wav", MediaKind.audio)
    ])
    func recognizesNativeFormats(filename: String, expectedKind: MediaKind) {
        let result = MediaFormatSupport.classify(URL(fileURLWithPath: filename))

        #expect(result == .native(expectedKind))
    }

    @Test("Container formats needing a codec pack are identified", arguments: ["movie.mkv", "clip.avi", "audio.flac", "music.ogg"])
    func recognizesCodecPackFormats(filename: String) {
        let result = MediaFormatSupport.classify(URL(fileURLWithPath: filename))

        #expect(result == .codecPackRecommended)
    }

    @Test("Non-media documents are rejected")
    func rejectsNonMedia() {
        #expect(MediaFormatSupport.classify(URL(fileURLWithPath: "invoice.pdf")) == .unsupported)
    }
}
