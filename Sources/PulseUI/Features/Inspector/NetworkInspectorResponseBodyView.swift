// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

#if !os(macOS)

struct NetworkInspectorResponseBodyView: View {
    let viewModel: NetworkInspectorResponseBodyViewModel

    var body: some View {
        contents
            .inlineNavigationTitle(L10n.tr("pulse.network.response_body"))
    }

    @ViewBuilder
    var contents: some View {
        if let viewModel = viewModel.fileViewModel {
            FileViewer(viewModel: viewModel)
                .onDisappear { self.viewModel.onDisappear() }
        } else if viewModel.task.type == .downloadTask {
            PlaceholderView(imageName: "arrow.down.circle", title: {
                var title = L10n.tr("pulse.network.downloaded_to_file")
                if viewModel.task.responseBodySize > 0 {
                    title = "\(ByteCountFormatter.string(fromByteCount: viewModel.task.responseBodySize))\n\(title)"
                }
                return title
            }())
        } else if viewModel.task.responseBodySize > 0 {
            PlaceholderView(imageName: "exclamationmark.circle", title: L10n.tr("pulse.common.unavailable"), subtitle: L10n.tr("pulse.network.response_body_unavailable"))
        } else {
            PlaceholderView(imageName: "nosign", title: L10n.tr("pulse.network.empty_response"))
        }
    }
}

#endif

final class NetworkInspectorResponseBodyViewModel {
    private(set) lazy var fileViewModel = data.map { data in
        FileViewerViewModel(
            title: L10n.tr("pulse.network.response_body"),
            context: task.responseFileViewerContext,
            data: { data }
        )
    }

    private var data: Data? {
        guard let data = task.responseBody?.data, !data.isEmpty else { return nil }
        return data
    }

    let task: NetworkTaskEntity

    init(task: NetworkTaskEntity) {
        self.task = task
    }

    func onDisappear() {
        task.responseBody?.reset()
    }
}
