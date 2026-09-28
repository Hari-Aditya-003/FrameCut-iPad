import AVFoundation
import Combine
import Foundation

@MainActor
final class PlayerController: ObservableObject {
    @Published private(set) var library: [MediaItem] = []
    @Published private(set) var selectedItem: MediaItem?
    @Published private(set) var isLoading = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var exportURL: URL?
    @Published private(set) var isExporting = false
    @Published var trimRange = TrimRange.full(duration: 0)
    @Published var isLoopingTrim = false
    @Published var presentationMode: PlayerPresentationMode = .fit
    @Published var notice: WorkspaceNotice?
    @Published var volume: Float = 1 {
        didSet { player.volume = min(max(volume, 0), 1) }
    }
    @Published var isMuted = false {
        didSet { player.isMuted = isMuted }
    }
    @Published var speed: PlaybackSpeed = .normal {
        didSet {
            if isPlaying { player.rate = speed.rawValue }
        }
    }

    let player = AVPlayer()
    private var timeObserver: Any?
    private var accessedSecurityScopedURLs = Set<URL>()

    init() {
        configureAudioSession()
        observeTime()
    }

    func importURLs(_ urls: [URL]) {
        var firstNewItem: MediaItem?
        var codecWarnings = [String]()

        for url in urls {
            switch MediaFormatSupport.classify(url) {
            case .native(let kind):
                guard !library.contains(where: { $0.url == url }) else { continue }
                if url.startAccessingSecurityScopedResource() {
                    accessedSecurityScopedURLs.insert(url)
                }
                let item = MediaItem(url: url, kind: kind)
                library.append(item)
                firstNewItem = firstNewItem ?? item
            case .codecPackRecommended:
                codecWarnings.append(url.lastPathComponent)
            case .unsupported:
                notice = .error("\(url.lastPathComponent) is not a recognized media file.")
            }
        }

        if !codecWarnings.isEmpty {
            notice = .info("A VLC codec pack is needed for: \(codecWarnings.joined(separator: ", ")).")
        }
        if let firstNewItem {
            select(firstNewItem)
        }
    }

    func select(_ item: MediaItem) {
        guard selectedItem?.id != item.id else { return }
        let selectedID = item.id
        selectedItem = item
        isLoading = true
        isPlaying = false
        currentTime = 0
        duration = 0
        trimRange = .full(duration: 0)
        exportURL = nil
        player.pause()

        let asset = AVURLAsset(url: item.url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        Task { [weak self] in
            guard let self else { return }
            do {
                let loadedDuration = try await asset.load(.duration)
                let isPlayable = try await asset.load(.isPlayable)
                guard isPlayable else {
                    throw PlayerError.notPlayable
                }
                guard selectedItem?.id == selectedID else { return }
                let seconds = loadedDuration.seconds.isFinite ? max(0, loadedDuration.seconds) : 0
                duration = seconds
                trimRange = .full(duration: seconds)
                isLoading = false
            } catch {
                guard selectedItem?.id == selectedID else { return }
                isLoading = false
                notice = .error("FrameCut could not open this file. Its codec may not be supported by Apple’s media engine.")
            }
        }
    }

    func remove(_ item: MediaItem) {
        library.removeAll { $0.id == item.id }
        if selectedItem?.id == item.id {
            player.pause()
            player.replaceCurrentItem(with: nil)
            selectedItem = nil
            isLoading = false
            isPlaying = false
            currentTime = 0
            duration = 0
            trimRange = .full(duration: 0)
            exportURL = nil
            if let next = library.first {
                select(next)
            }
        }
        if accessedSecurityScopedURLs.remove(item.url) != nil {
            item.url.stopAccessingSecurityScopedResource()
        }
    }

    func togglePlayback() {
        guard player.currentItem != nil else { return }
        if isPlaying {
            pause()
        } else {
            if currentTime >= duration - 0.05 { seek(to: 0) }
            player.playImmediately(atRate: speed.rawValue)
            isPlaying = true
        }
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func seek(to seconds: TimeInterval) {
        let safeTime = min(max(0, seconds), duration)
        let time = CMTime(seconds: safeTime, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = safeTime
    }

    func jump(by seconds: TimeInterval) {
        seek(to: currentTime + seconds)
    }

    func moveTrimStart(to seconds: TimeInterval) {
        trimRange = trimRange.movingStart(to: seconds)
        seek(to: trimRange.start)
    }

    func moveTrimEnd(to seconds: TimeInterval) {
        trimRange = trimRange.movingEnd(to: seconds)
        seek(to: trimRange.end)
    }

    func nudgeTrimStart(by seconds: TimeInterval) {
        moveTrimStart(to: trimRange.start + seconds)
    }

    func nudgeTrimEnd(by seconds: TimeInterval) {
        moveTrimEnd(to: trimRange.end + seconds)
    }

    func previewTrim() {
        guard player.currentItem != nil, trimRange.length > 0 else { return }
        seek(to: trimRange.start)
        player.playImmediately(atRate: speed.rawValue)
        isPlaying = true
    }

    func resetTrim() {
        trimRange = .full(duration: duration)
        seek(to: 0)
    }

    func toggleMute() {
        isMuted.toggle()
    }

    func adjustVolume(by amount: Float) {
        setVolume(volume + amount)
    }

    func setVolume(_ value: Float) {
        volume = min(max(value, 0), 1)
        if volume > 0 {
            isMuted = false
        }
    }

    func dismissNotice() {
        notice = nil
    }

    func exportTrim() {
        guard let item = selectedItem, trimRange.length > 0 else { return }
        isExporting = true
        exportURL = nil
        let selectedRange = trimRange

        Task { [weak self] in
            guard let self else { return }
            do {
                let url = try await TrimExporter.export(item: item, range: selectedRange)
                exportURL = url
                isExporting = false
                notice = .info("Export complete. Use Share to save the trimmed clip to Files or Photos.")
            } catch {
                isExporting = false
                notice = .error("Export failed: \(error.localizedDescription)")
            }
        }
    }

    private func observeTime() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.currentTime = max(0, time.seconds.isFinite ? time.seconds : 0)
                if self.isLoopingTrim,
                   self.isPlaying,
                   self.trimRange.length > 0,
                   self.currentTime >= self.trimRange.end {
                    self.seek(to: self.trimRange.start)
                    self.player.playImmediately(atRate: self.speed.rawValue)
                }
                if self.duration > 0, self.currentTime >= self.duration - 0.05 {
                    self.isPlaying = false
                }
            }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            notice = .info("Audio routing will use the current system settings.")
        }
    }
}

private enum PlayerError: LocalizedError {
    case notPlayable

    var errorDescription: String? { "This media is not playable." }
}
