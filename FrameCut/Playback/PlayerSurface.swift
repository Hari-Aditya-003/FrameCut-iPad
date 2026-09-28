import AVFoundation
import AVKit
import SwiftUI

struct PlayerSurface: UIViewControllerRepresentable {
    let player: AVPlayer
    let presentationMode: PlayerPresentationMode

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.updatesNowPlayingInfoCenter = true
        controller.videoGravity = gravity
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        controller.player = player
        controller.videoGravity = gravity
    }

    private var gravity: AVLayerVideoGravity {
        switch presentationMode {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .stretch: .resize
        }
    }
}

struct RoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = true
        view.tintColor = .secondaryLabel
        view.activeTintColor = UIColor(Color.accentColor)
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
