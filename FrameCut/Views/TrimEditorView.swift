import SwiftUI

struct TrimEditorView: View {
    @ObservedObject var controller: PlayerController
    let item: MediaItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Label("Precision trim", systemImage: "timeline.selection")
                        .font(.headline)
                    Text("Drag the in and out handles, or nudge by 0.1 seconds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(TimecodeFormatter.preciseString(seconds: controller.trimRange.length)) selected")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(FrameCutTheme.secondaryAccent)
            }

            TrimTimelineView(
                kind: item.kind,
                range: controller.trimRange,
                duration: controller.duration,
                moveStart: controller.moveTrimStart,
                moveEnd: controller.moveTrimEnd
            )
            .frame(height: 78)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 16) {
                    boundaryControls
                    Spacer(minLength: 12)
                    previewControls
                    exportControls
                }
                VStack(spacing: 14) {
                    boundaryControls
                    HStack { previewControls; Spacer(); exportControls }
                }
            }
        }
        .padding(18)
        .panelStyle()
    }

    private var boundaryControls: some View {
        HStack(spacing: 10) {
            TimeBoundaryControl(
                title: "IN",
                time: controller.trimRange.start,
                decrement: { controller.nudgeTrimStart(by: -0.1) },
                increment: { controller.nudgeTrimStart(by: 0.1) }
            )
            TimeBoundaryControl(
                title: "OUT",
                time: controller.trimRange.end,
                decrement: { controller.nudgeTrimEnd(by: -0.1) },
                increment: { controller.nudgeTrimEnd(by: 0.1) }
            )
        }
    }

    private var previewControls: some View {
        HStack(spacing: 10) {
            Button(action: controller.previewTrim) {
                Label("Preview", systemImage: "play.fill")
            }
            .buttonStyle(.bordered)

            Toggle(isOn: $controller.isLoopingTrim) {
                Image(systemName: "repeat")
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .accessibilityLabel("Loop trim preview")

            Button(action: controller.resetTrim) {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Reset trim")
        }
    }

    private var exportControls: some View {
        HStack(spacing: 10) {
            Button(action: controller.exportTrim) {
                if controller.isExporting {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Export", systemImage: "scissors")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(controller.isExporting || controller.duration <= 0)

            if let exportURL = controller.exportURL {
                ShareLink(item: exportURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct TimeBoundaryControl: View {
    let title: String
    let time: TimeInterval
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            Button(action: decrement) {
                Image(systemName: "minus")
                    .frame(width: 26, height: 32)
            }
            .accessibilityLabel("Move \(title) back 0.1 seconds")

            VStack(spacing: 1) {
                Text(title)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Text(TimecodeFormatter.preciseString(seconds: time))
                    .font(.caption.monospacedDigit().weight(.semibold))
            }
            .frame(minWidth: 58)

            Button(action: increment) {
                Image(systemName: "plus")
                    .frame(width: 26, height: 32)
            }
            .accessibilityLabel("Move \(title) forward 0.1 seconds")
        }
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct TrimTimelineView: View {
    let kind: MediaKind
    let range: TrimRange
    let duration: TimeInterval
    let moveStart: (TimeInterval) -> Void
    let moveEnd: (TimeInterval) -> Void

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let startX = xPosition(for: range.start, width: width)
            let endX = xPosition(for: range.end, width: width)

            ZStack(alignment: .leading) {
                TimelineTexture(kind: kind)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Rectangle()
                    .fill(.black.opacity(0.62))
                    .frame(width: max(0, startX))
                Rectangle()
                    .fill(.black.opacity(0.62))
                    .frame(width: max(0, width - endX))
                    .offset(x: endX)

                Rectangle()
                    .fill(FrameCutTheme.accent.opacity(0.12))
                    .frame(width: max(0, endX - startX))
                    .offset(x: startX)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(FrameCutTheme.accent)
                            .frame(width: 2)
                            .offset(x: startX)
                    }

                trimHandle(title: "IN", x: startX, width: width, action: moveStart)
                trimHandle(title: "OUT", x: endX, width: width, action: moveEnd)
            }
            .coordinateSpace(name: "timeline")
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.white.opacity(0.13))
            }
        }
    }

    private func trimHandle(title: String, x: CGFloat, width: CGFloat, action: @escaping (TimeInterval) -> Void) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(.black)
            Capsule()
                .fill(.black.opacity(0.75))
                .frame(width: 3, height: 42)
        }
        .frame(width: 24, height: 72)
        .background(FrameCutTheme.accent, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .position(x: min(max(12, x), width - 12), y: 39)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("timeline"))
                .onChanged { value in
                    guard duration > 0 else { return }
                    action((min(max(0, value.location.x), width) / width) * duration)
                }
        )
        .accessibilityLabel("\(title) trim handle")
        .accessibilityValue(TimecodeFormatter.preciseString(seconds: title == "IN" ? range.start : range.end))
    }

    private func xPosition(for time: TimeInterval, width: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        return min(max(0, time / duration), 1) * width
    }
}

private struct TimelineTexture: View {
    let kind: MediaKind

    var body: some View {
        Canvas { context, size in
            let count = 24
            let cellWidth = size.width / CGFloat(count)
            for index in 0..<count {
                let hue = Double(index) / Double(count)
                let color = kind == .video
                    ? Color(hue: 0.56 + hue * 0.08, saturation: 0.35, brightness: 0.32 + (index.isMultiple(of: 3) ? 0.12 : 0))
                    : FrameCutTheme.secondaryAccent.opacity(index.isMultiple(of: 2) ? 0.5 : 0.3)
                let height = kind == .video
                    ? size.height
                    : size.height * (0.25 + CGFloat((index * 17) % 70) / 100)
                let rect = CGRect(
                    x: CGFloat(index) * cellWidth + 1,
                    y: (size.height - height) / 2,
                    width: max(1, cellWidth - 2),
                    height: height
                )
                context.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(color))
            }
        }
        .background(Color.white.opacity(0.04))
    }
}
