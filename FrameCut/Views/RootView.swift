import SwiftUI
import UniformTypeIdentifiers

struct RootView: View {
    @ObservedObject var controller: PlayerController
    @State private var isImporting = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            LibraryView(controller: controller) {
                isImporting = true
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 290, max: 340)
        } detail: {
            PlayerWorkspaceView(controller: controller) {
                isImporting = true
            }
        }
        .navigationSplitViewStyle(.balanced)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.audiovisualContent, .audio, .movie, .item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls): controller.importURLs(urls)
            case .failure(let error): controller.notice = .error("Import failed: \(error.localizedDescription)")
            }
        }
        .alert(
            "FrameCut",
            isPresented: Binding(
                get: { controller.notice != nil },
                set: { if !$0 { controller.dismissNotice() } }
            )
        ) {
            Button("OK") { controller.dismissNotice() }
        } message: {
            Text(controller.notice?.message ?? "")
        }
    }
}

#Preview {
    RootView(controller: PlayerController())
}
