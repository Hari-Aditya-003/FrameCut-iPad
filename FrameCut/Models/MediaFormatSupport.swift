import Foundation

nonisolated enum MediaKind: String, Equatable, Sendable {
    case video
    case audio
}

nonisolated enum MediaSupport: Equatable, Sendable {
    case native(MediaKind)
    case codecPackRecommended
    case unsupported
}

nonisolated enum MediaFormatSupport {
    private static let nativeVideo = Set(["mp4", "mov", "m4v"])
    private static let nativeAudio = Set(["mp3", "m4a", "aac", "wav", "aif", "aiff", "caf"])
    private static let expandedCodecFormats = Set(["mkv", "avi", "webm", "flv", "wmv", "ts", "mts", "m2ts", "flac", "ogg", "opus", "wma"])

    static func classify(_ url: URL) -> MediaSupport {
        let fileExtension = url.pathExtension.lowercased()
        if nativeVideo.contains(fileExtension) { return .native(.video) }
        if nativeAudio.contains(fileExtension) { return .native(.audio) }
        if expandedCodecFormats.contains(fileExtension) { return .codecPackRecommended }
        return .unsupported
    }
}
