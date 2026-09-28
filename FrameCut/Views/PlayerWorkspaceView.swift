import SwiftUI

struct PlayerWorkspaceView: View {
    @ObservedObject var controller: PlayerController
    let onImport: () -> Void

    var body: some View {
        ZStack {
            FrameCutTheme.canvas.ignoresSafeArea()
            ambientBackground

            if let item = controller.selectedItem {
                ScrollView {
                    VStack(spacing: 16) {
                        workspaceHeader(for: item)
                        PlaybackCanvas(controller: controller, item: item)
                        TransportControls(controller: controller)
                        TrimEditorView(controller: controller, item: item)
                    }
                    .padding(20)
                    .frame(maxWidth: 1_100)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            } else {
                emptyWorkspace
            }
        }
        .navigationTitle(controller.selectedItem?.title ?? "FrameCut")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var ambientBackground: some View {
        GeometryReader { proxy in
            Circle()
                .fill(FrameCutTheme.accent.opacity(0.09))
                .frame(width: proxy.size.width * 0.6)
                .blur(radius: 100)
                .offset(x: proxy.size.width * 0.45, y: -proxy.size.height * 0.2)
            Circle()
                .fill(FrameCutTheme.secondaryAccent.opacity(0.07))
                .frame(width: proxy.size.width * 0.5)
                .blur(radius: 110)
                .offset(x: -proxy.size.width * 0.12, y: proxy.size.height * 0.65)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func workspaceHeader(for item: MediaItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.title2.bold())
                    .lineLimit(1)
                Text("\(item.fileExtension) • \(item.kind == .video ? "VIDEO" : "AUDIO")")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }
            Spacer()
            if controller.isLoading {
                ProgressView()
                    .controlSize(.small)
                Text("Loading")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var emptyWorkspace: some View {
        ContentUnavailableView {
            Label("Open your first file", systemImage: "play.square.stack")
        } description: {
            Text("Play video or audio, set a precise range, then export just the moment you need.")
        } actions: {
            Button("Choose from Files", action: onImport)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
    }
}

private struct PlaybackCanvas: View {
    @ObservedObject var controller: PlayerController
    let item: MediaItem
    @State private var isFullScreen = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.black)

            if item.kind == .video {
                PlayerSurface(player: controller.player, presentationMode: controller.presentationMode)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                audioArtwork
            }

            if controller.isLoading {
                ProgressView("Reading media…")
                    .padding(18)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }

            VStack {
                HStack {
                    Spacer()
                    Menu {
                        Picker("Video size", selection: $controller.presentationMode) {
                            ForEach(PlayerPresentationMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                    } label: {
                        Label(controller.presentationMode.rawValue, systemImage: "aspectratio")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .accessibilityLabel("Video size: \(controller.presentationMode.rawValue)")

                    if item.kind == .video {
                        Button {
                            isFullScreen = true
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.caption.weight(.semibold))
                                .frame(width: 34, height: 34)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Enter full screen")
                    }
                }
                Spacer()
            }
            .padding(14)
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(maxHeight: 520)
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.1))
        }
        .shadow(color: .black.opacity(0.3), radius: 24, y: 12)
        .fullScreenCover(isPresented: $isFullScreen) {
            ZStack {
                Color.black.ignoresSafeArea()
                PlayerSurface(player: controller.player, presentationMode: controller.presentationMode)
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isFullScreen = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Exit full screen")
                    }
                    Spacer()
                    TransportControls(controller: controller)
                        .frame(maxWidth: 900)
                }
                .padding(24)
            }
            .statusBarHidden(true)
        }
    }

    private var audioArtwork: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.08, blue: 0.18), Color(red: 0.04, green: 0.16, blue: 0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 18) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 82, weight: .light))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(FrameCutTheme.accent, FrameCutTheme.secondaryAccent.opacity(0.3))
                Text(item.title)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
