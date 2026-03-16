// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if !os(macOS)

import SwiftUI
import Pulse

struct NetworkInspectorRequestBodyView: View {
    let viewModel: NetworkInspectorRequestBodyViewModel

    var body: some View {
        contents
            .inlineNavigationTitle(L10n.tr("pulse.network.request_body"))
    }

    @ViewBuilder
    private var contents: some View {
        if let viewModel = viewModel.fileViewModel {
            FileViewer(viewModel: viewModel)
                .onDisappear { self.viewModel.onDisappear() }
        } else if viewModel.task.type == .uploadTask {
            PlaceholderView(imageName: "arrow.up.circle", title: {
                var title = L10n.tr("pulse.network.uploaded_from_file")
                if viewModel.task.requestBodySize > 0 {
                    title = "\(ByteCountFormatter.string(fromByteCount: viewModel.task.requestBodySize))\n\(title)"
                }
                return title
            }())
        } else if viewModel.task.requestBodySize > 0 {
            PlaceholderView(imageName: "exclamationmark.circle", title: L10n.tr("pulse.common.unavailable"), subtitle: L10n.tr("pulse.network.request_body_unavailable"))
        } else {
            PlaceholderView(imageName: "nosign", title: L10n.tr("pulse.network.empty_request"))
        }
    }
}

final class NetworkInspectorRequestBodyViewModel {
    private(set) lazy var fileViewModel = data.map { data in
        FileViewerViewModel(
            title: L10n.tr("pulse.network.request_body"),
            context: task.requestFileViewerContext,
            data: { data }
        )
    }

    private var data: Data? {
        guard let data = task.requestBody?.data, !data.isEmpty else { return nil }
        return data
    }

    let task: NetworkTaskEntity

    init(task: NetworkTaskEntity) {
        self.task = task
    }

    func onDisappear() {
        task.requestBody?.reset()
    }
}

#endif
