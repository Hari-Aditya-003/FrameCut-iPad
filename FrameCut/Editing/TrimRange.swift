import Foundation

nonisolated struct TrimRange: Equatable, Sendable {
    let start: TimeInterval
    let end: TimeInterval
    let duration: TimeInterval
    let minimumLength: TimeInterval

    var length: TimeInterval { max(0, end - start) }
    var progressBounds: ClosedRange<Double> {
        guard duration > 0 else { return 0...0 }
        return (start / duration)...(end / duration)
    }

    init(
        start: TimeInterval,
        end: TimeInterval,
        duration: TimeInterval,
        minimumLength: TimeInterval = 0.1
    ) {
        let safeDuration = duration.isFinite ? max(0, duration) : 0
        let safeMinimum = minimumLength.isFinite ? max(0, minimumLength) : 0

        self.duration = safeDuration
        self.minimumLength = min(safeMinimum, safeDuration)

        guard safeDuration > 0 else {
            self.start = 0
            self.end = 0
            return
        }

        let clampedStart = max(0, min(start.isFinite ? start : 0, safeDuration))
        let clampedEnd = max(0, min(end.isFinite ? end : safeDuration, safeDuration))
        self.start = min(clampedStart, max(0, clampedEnd - self.minimumLength))
        self.end = max(clampedEnd, self.start + self.minimumLength)
    }

    static func full(duration: TimeInterval, minimumLength: TimeInterval = 0.1) -> TrimRange {
        TrimRange(start: 0, end: duration, duration: duration, minimumLength: minimumLength)
    }

    func movingStart(to value: TimeInterval) -> TrimRange {
        TrimRange(
            start: min(max(0, value), end - minimumLength),
            end: end,
            duration: duration,
            minimumLength: minimumLength
        )
    }

    func movingEnd(to value: TimeInterval) -> TrimRange {
        TrimRange(
            start: start,
            end: max(min(duration, value), start + minimumLength),
            duration: duration,
            minimumLength: minimumLength
        )
    }
}
