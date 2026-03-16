// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

@available(iOS 16, tvOS 16, macOS 13, watchOS 9, visionOS 1, *)
struct StoreDetailsView: View {
    @StateObject private var viewModel = StoreDetailsViewModel()

    let source: StoreDetailsViewSource

    var body: some View {
        StoreDetailsContentsView(viewModel: viewModel)
            .task { await viewModel.load(from: source) }
#if os(tvOS)
            .padding()
#else
            .inlineNavigationTitle(L10n.tr("pulse.store.details_title"))
#endif
    }
}

@available(iOS 16, tvOS 16, macOS 13, watchOS 9, visionOS 1, *)
struct StoreDetailsContentsView: View {
    @ObservedObject var viewModel: StoreDetailsViewModel
    @Environment(\.store) var store
    var isShowingActions = true

    var body: some View {
        // important: zstack fixed infinite onAppear loop on iOS 14
        ZStack {
            if let error = viewModel.errorMessage {
                PlaceholderView(imageName: "exclamationmark.circle", title: L10n.tr("pulse.store.failed_to_load_info"), subtitle: error)
            } else {
                form
            }
        }
    }

    @ViewBuilder
    private var form: some View {
        Form {
            if let info = viewModel.info {
                LoggerStoreSizeChart(info: info, sizeLimit: viewModel.storeSizeLimit)
#if os(tvOS)
                    .padding(.vertical)
                    .focusable()
#endif
#if os(macOS)
                    .padding(12)
#endif
            }
            ForEach(viewModel.sections, id: \.title) { section in
                ConsoleSection(header: {
#if os(macOS)
                    SectionHeaderView(title: section.title)
#else
                    Text(section.title)
#endif
                }, content: {
                    ForEach(section.items.enumerated().map(KeyValueRow.init)) { item in
                        InfoRow(title: item.title, details: item.details)
#if os(tvOS)
                            .focusable()
#endif
                    }
                })
            }
#if os(macOS)
            if isShowingActions {
                ConsoleSection(header: { EmptyView() }, content: {
                    HStack {
                        Button(L10n.tr("pulse.store.show_in_finder")) {
                            NSWorkspace.shared.activateFileViewerSelecting([store.storeURL])
                        }
                        if !(store.options.contains(.readonly)) {
                            Button(L10n.tr("pulse.store.remove_logs")) {
                                store.removeAll()
                            }
                        }
                    }
                })
            }
#endif
        }
    }
}

enum StoreDetailsViewSource {
    /// Loads the info when the view appears on screen.
    case store(LoggerStore)
    /// Displays prefetched info.
    case info(LoggerStore.Info)
}

// MARK: - ViewModel

@MainActor final class StoreDetailsViewModel: ObservableObject {
    @Published private(set) var storeSizeLimit: Int64?
    @Published private(set) var sections: [KeyValueSectionViewModel] = []
    @Published private(set) var info: LoggerStore.Info?
    @Published private(set) var errorMessage: String?

    func load(from source: StoreDetailsViewSource) async {
        switch source {
        case .store(let store):
            await loadInfo(for: store)
        case .info(let value):
            display(value)
        }
    }

    private func loadInfo(for store: LoggerStore) async {
        do {
            let info = try await store.info()
            if store === LoggerStore.shared {
                self.storeSizeLimit = store.configuration.sizeLimit
            }
            self.display(info)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func display(_ info: LoggerStore.Info) {
        self.info = info
        self.sections = [
            makeSizeSection(for: info),
            makeInfoSection(for: info)
        ]
    }

    private func makeInfoSection(for info: LoggerStore.Info) -> KeyValueSectionViewModel {
        let device = info.deviceInfo
        let app = info.appInfo
        return KeyValueSectionViewModel(title: L10n.tr("pulse.store.app_info"), color: .gray, items: [
            (L10n.tr("pulse.store.app"), "\(app.name ?? "–") \(app.version ?? "–") (\(app.build ?? "–"))"),
            (L10n.tr("pulse.store.device"), "\(device.name) (\(device.systemName) \(device.systemVersion))")
        ])
    }

    private func makeSizeSection(for info: LoggerStore.Info) -> KeyValueSectionViewModel {
        KeyValueSectionViewModel(title: L10n.tr("pulse.store.statistics"), color: .gray, items: [
            (L10n.tr("pulse.store.created"), dateFormatter.string(from: info.creationDate)),
            (L10n.tr("pulse.store.messages"), info.messageCount.description),
            (L10n.tr("pulse.store.requests"), info.taskCount.description),
            (L10n.tr("pulse.store.blobs_size"), ByteCountFormatter.string(fromByteCount: info.blobsSize)),
            makeDecompressedRow(for: info)
        ].compactMap { $0 })
    }

    private func makeDecompressedRow(for info: LoggerStore.Info) -> (String, String?)? {
        if info.blobsDecompressedSize == info.blobsSize {
            return nil
        }
        return (L10n.tr("pulse.store.blobs_size_decompressed"), ByteCountFormatter.string(fromByteCount: info.blobsDecompressedSize))
    }
}

private let dateFormatter = DateFormatter(dateStyle: .medium, timeStyle: .medium)

#if DEBUG
@available(iOS 16, tvOS 16, macOS 13, watchOS 9, visionOS 1, *)
struct StoreDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        StoreDetailsView(source: .store(.mock))
            .frame(width: 280)
    }
}
#endif
