// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import Combine

struct NetworkInspectorRequestView: View {
    @ObservedObject var viewModel: NetworkInspectorRequestViewModel
    let onToggleExpanded: () -> Void

    var body: some View {
        if let viewModel = viewModel.fileViewModel {
            FileViewer(viewModel: viewModel, onToggleExpanded: onToggleExpanded)
                .onDisappear { self.viewModel.onDisappear() }
        } else if viewModel.task.state == .pending {
            SpinnerView(viewModel: viewModel.progress)
        } else if viewModel.task.type == .uploadTask {
            PlaceholderView(imageName: "arrow.up.circle", title: {
                var title = L10n.tr("pulse.network.uploaded_from_file")
                if viewModel.task.requestBodySize > 0 {
                    title = "\(ByteCountFormatter.string(fromByteCount: viewModel.task.requestBodySize))\n\(title)"
                }
                return title
            }())
        } else if viewModel.task.requestBodySize > 0 {
            PlaceholderView(imageName: "exclamationmark.circle", title: L10n.tr("pulse.common.unavailable"), subtitle: L10n.tr("pulse.network.request_body_deleted"))
        } else {
            PlaceholderView(imageName: "nosign", title: L10n.tr("pulse.network.empty_request"))
        }
    }
}

final class NetworkInspectorRequestViewModel: ObservableObject {
    private(set) lazy var progress = ProgressViewModel(task: task)
    var fileViewModel: FileViewerViewModel? {
        if let viewModel = _fileViewModel {
            return viewModel
        }
        if let requestBody = task.requestBody?.data {
            _fileViewModel = FileViewerViewModel(
                title: L10n.tr("pulse.network.request"),
                context: task.requestFileViewerContext,
                data: { requestBody }
            )
        }
        return _fileViewModel
    }

    private var _fileViewModel: FileViewerViewModel?

    let task: NetworkTaskEntity
    private var cancellable: AnyCancellable?

    init(task: NetworkTaskEntity) {
        self.task = task
        cancellable = task.objectWillChange.sink { [weak self] in self?.refresh() }
    }

    func onDisappear() {
        task.requestBody?.reset()
    }

    private func refresh() {
        withAnimation { objectWillChange.send() }
    }
}
