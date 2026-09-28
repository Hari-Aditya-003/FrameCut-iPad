import Foundation

struct MediaItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let url: URL
    let title: String
    let kind: MediaKind
    let fileExtension: String

    init(id: UUID = UUID(), url: URL, kind: MediaKind) {
        self.id = id
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.kind = kind
        self.fileExtension = url.pathExtension.uppercased()
    }
}

enum PlayerPresentationMode: String, CaseIterable, Identifiable, Sendable {
    case fit = "Fit"
    case fill = "Fill"
    case stretch = "Stretch"

    var id: Self { self }
}

enum PlaybackSpeed: Float, CaseIterable, Identifiable, Sendable {
    case half = 0.5
    case normal = 1
    case oneAndHalf = 1.5
    case double = 2

    var id: Self { self }
    var title: String { rawValue.formatted() + "×" }
}

enum WorkspaceNotice: Identifiable, Equatable, Sendable {
    case info(String)
    case error(String)

    var id: String {
        switch self {
        case .info(let message): "info-\(message)"
        case .error(let message): "error-\(message)"
        }
    }

    var message: String {
        switch self {
        case .info(let message), .error(let message): message
        }
    }
}
