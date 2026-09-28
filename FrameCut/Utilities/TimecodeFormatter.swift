import Foundation

nonisolated enum TimecodeFormatter {
    static func string(seconds: TimeInterval) -> String {
        let safeSeconds = seconds.isFinite ? max(0, Int(seconds.rounded(.down))) : 0
        let hours = safeSeconds / 3_600
        let minutes = (safeSeconds % 3_600) / 60
        let remainingSeconds = safeSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        }
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    static func preciseString(seconds: TimeInterval) -> String {
        let safeSeconds = seconds.isFinite ? max(0, seconds) : 0
        let roundedTenths = Int((safeSeconds * 10).rounded())
        let minutes = roundedTenths / 600
        let remaining = Double(roundedTenths % 600) / 10
        return String(format: "%02d:%04.1f", minutes, remaining)
    }
}
