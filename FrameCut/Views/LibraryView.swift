import SwiftUI

struct LibraryView: View {
    @ObservedObject var controller: PlayerController
    let onImport: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FrameCutTheme.canvas, Color(red: 0.07, green: 0.08, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                brand

                Button(action: onImport) {
                    Label("Add media", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 14))
                .keyboardShortcut("o", modifiers: .command)

                Text("SESSION LIBRARY")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1.4)

                if controller.library.isEmpty {
                    libraryEmptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(controller.library) { item in
                                MediaRow(
                                    item: item,
                                    isSelected: controller.selectedItem?.id == item.id,
                                    select: { controller.select(item) },
                                    remove: { controller.remove(item) }
                                )
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }

                Spacer(minLength: 0)
                codecNote
            }
            .padding(20)
        }
        .navigationTitle("Library")
        .toolbar(.hidden, for: .navigationBar)
    }

    private var brand: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(FrameCutTheme.accent.gradient)
                    .frame(width: 48, height: 48)
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("FrameCut")
                    .font(.title2.bold())
                Text("PLAYER + TRIMMER")
                    .font(.caption2.bold())
                    .tracking(1.1)
                    .foregroundStyle(FrameCutTheme.secondaryAccent)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var libraryEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(FrameCutTheme.secondaryAccent)
            Text("Your imported videos and audio appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .panelStyle()
    }

    private var codecNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(FrameCutTheme.secondaryAccent)
            Text("MP4, MOV, M4V, MP3, M4A, WAV and AIFF use Apple’s native engine. MKV/AVI/FLAC need the optional VLC codec pack.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .panelStyle()
    }
}

private struct MediaRow: View {
    let item: MediaItem
    let isSelected: Bool
    let select: () -> Void
    let remove: () -> Void

    var body: some View {
        Button(action: select) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(isSelected ? FrameCutTheme.accent.opacity(0.25) : .white.opacity(0.07))
                        .frame(width: 44, height: 44)
                    Image(systemName: item.kind == .video ? "film.fill" : "waveform")
                        .foregroundStyle(isSelected ? FrameCutTheme.accent : FrameCutTheme.secondaryAccent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(item.fileExtension.isEmpty ? item.kind.rawValue.uppercased() : item.fileExtension)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                if isSelected {
                    Image(systemName: "play.fill")
                        .font(.caption)
                        .foregroundStyle(FrameCutTheme.accent)
                }
            }
            .padding(10)
            .contentShape(Rectangle())
            .background(isSelected ? .white.opacity(0.09) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: remove) {
                Label("Remove from library", systemImage: "trash")
            }
        }
        .accessibilityHint(isSelected ? "Currently selected" : "Opens this media")
    }
}
