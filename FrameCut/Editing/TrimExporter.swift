import AVFoundation
import Foundation

enum TrimExporter {
    @MainActor
    static func export(item: MediaItem, range: TrimRange) async throws -> URL {
        let asset = AVURLAsset(url: item.url)
        let preset = item.kind == .audio ? AVAssetExportPresetAppleM4A : AVAssetExportPresetHighestQuality
        guard let session = AVAssetExportSession(asset: asset, presetName: preset) else {
            throw ExportError.cannotCreateSession
        }

        let start = CMTime(seconds: range.start, preferredTimescale: 600)
        let length = CMTime(seconds: range.length, preferredTimescale: 600)
        session.timeRange = CMTimeRange(start: start, duration: length)
        session.shouldOptimizeForNetworkUse = true

        let fileType: AVFileType
        let fileExtension: String
        if item.kind == .audio {
            fileType = .m4a
            fileExtension = "m4a"
        } else if session.supportedFileTypes.contains(.mp4) {
            fileType = .mp4
            fileExtension = "mp4"
        } else {
            fileType = .mov
            fileExtension = "mov"
        }

        let safeTitle = item.title.replacingOccurrences(of: "/", with: "-")
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeTitle)-trim-\(UUID().uuidString.prefix(6)).\(fileExtension)")

        try await session.export(to: outputURL, as: fileType)
        return outputURL
    }
}

private enum ExportError: LocalizedError {
    case cannotCreateSession

    var errorDescription: String? { "A compatible high-quality export session could not be created." }
}
