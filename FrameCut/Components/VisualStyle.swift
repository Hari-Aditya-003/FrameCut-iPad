import SwiftUI

enum FrameCutTheme {
    static let accent = Color(red: 1.0, green: 0.45, blue: 0.24)
    static let secondaryAccent = Color(red: 0.42, green: 0.80, blue: 0.92)
    static let canvas = Color(red: 0.035, green: 0.045, blue: 0.07)
}

struct PanelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.08))
            }
    }
}

extension View {
    func panelStyle() -> some View { modifier(PanelStyle()) }
}
