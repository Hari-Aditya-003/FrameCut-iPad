import SwiftUI

struct TransportControls: View {
    @ObservedObject var controller: PlayerController

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Text(TimecodeFormatter.string(seconds: controller.currentTime))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .frame(minWidth: 54, alignment: .leading)

                Slider(
                    value: Binding(
                        get: { controller.currentTime },
                        set: { controller.seek(to: $0) }
                    ),
                    in: 0...max(controller.duration, 0.01)
                )
                .accessibilityLabel("Playback position")
                .accessibilityValue("\(TimecodeFormatter.string(seconds: controller.currentTime)) of \(TimecodeFormatter.string(seconds: controller.duration))")

                Text(TimecodeFormatter.string(seconds: controller.duration))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 54, alignment: .trailing)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 18) { mainControls; Spacer(); audioControls }
                VStack(spacing: 14) {
                    mainControls
                    Divider().overlay(.white.opacity(0.08))
                    audioControls
                }
            }
        }
        .padding(16)
        .panelStyle()
    }

    private var mainControls: some View {
        HStack(spacing: 16) {
            transportButton("gobackward.10", label: "Back 10 seconds") {
                controller.jump(by: -10)
            }

            Button(action: controller.togglePlayback) {
                Image(systemName: controller.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .frame(width: 52, height: 52)
                    .background(FrameCutTheme.accent.gradient, in: Circle())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(controller.isPlaying ? "Pause" : "Play")

            transportButton("goforward.10", label: "Forward 10 seconds") {
                controller.jump(by: 10)
            }

            Menu {
                Picker("Playback speed", selection: $controller.speed) {
                    ForEach(PlaybackSpeed.allCases) { speed in
                        Text(speed.title).tag(speed)
                    }
                }
            } label: {
                Text(controller.speed.title)
                    .font(.subheadline.bold())
                    .frame(minWidth: 40, minHeight: 40)
                    .background(.white.opacity(0.07), in: Circle())
            }
            .accessibilityLabel("Playback speed, \(controller.speed.title)")
        }
    }

    private var audioControls: some View {
        HStack(spacing: 10) {
            Button(action: controller.toggleMute) {
                Image(systemName: volumeSymbol)
                    .frame(width: 30, height: 38)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(controller.isMuted ? "Unmute" : "Mute")

            Button {
                controller.adjustVolume(by: -0.1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 32, height: 38)
                    .background(.white.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Volume down")

            Slider(
                    value: Binding(
                        get: { Double(controller.volume) },
                        set: { controller.setVolume(Float($0)) }
                    ),
                in: 0...1
            )
            .frame(width: 130)
            .accessibilityLabel("Player volume")

            Button {
                controller.adjustVolume(by: 0.1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 32, height: 38)
                    .background(.white.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Volume up")

            RoutePicker()
                .frame(width: 38, height: 38)
                .accessibilityLabel("Choose audio output")
        }
    }

    private var volumeSymbol: String {
        if controller.isMuted || controller.volume == 0 { return "speaker.slash.fill" }
        if controller.volume < 0.4 { return "speaker.wave.1.fill" }
        return "speaker.wave.2.fill"
    }

    private func transportButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.07), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
