import SwiftUI

@main
struct FrameCutApp: App {
    @StateObject private var controller = PlayerController()

    var body: some Scene {
        WindowGroup {
            RootView(controller: controller)
                .tint(FrameCutTheme.accent)
                .preferredColorScheme(.dark)
        }
        .commands {
            CommandMenu("Playback") {
                Button(controller.isPlaying ? "Pause" : "Play") {
                    controller.togglePlayback()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Back 10 Seconds") { controller.jump(by: -10) }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                Button("Forward 10 Seconds") { controller.jump(by: 10) }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                Button("Mute") { controller.toggleMute() }
                    .keyboardShortcut("m", modifiers: [])
            }
        }
    }
}
