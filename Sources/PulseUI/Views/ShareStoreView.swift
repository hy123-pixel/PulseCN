// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)

import SwiftUI
import CoreData
import Pulse
import Combine

@available(iOS 16, macOS 13, watchOS 9, visionOS 1, *)
package struct ShareStoreView: View {
    /// Preselected sessions.
    var sessions: Set<UUID> = []
    var onDismiss: () -> Void

    @State private var isShowingLabelPicker = false
    @State private var isShowingPreparingForShareView = false
    @StateObject private var viewModel = ShareStoreViewModel()

    @Environment(\.store) private var store: LoggerStore

    package init(sessions: Set<UUID> = [], onDismiss: @escaping () -> Void) {
        self.sessions = sessions
        self.onDismiss = onDismiss
    }

    package var body: some View {
        content
            .onAppear {
                if !sessions.isEmpty {
                    viewModel.sessions = sessions
                } else if viewModel.sessions.isEmpty {
                    viewModel.sessions = [store.session.id]
                }
                viewModel.store = store
            }
    }

    @ViewBuilder
    private var content: some View {
#if os(iOS) || os(watchOS) || os(visionOS)
        Form {
            sectionSharingOptions
            sectionShare
        }
        .inlineNavigationTitle(L10n.tr("pulse.share.logs_title"))
        .toolbar {
#if os(watchOS)
            ToolbarItem(placement: .cancellationAction) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                }
            }
#else
            ToolbarItem(placement: .navigationBarLeading) {
                Button(L10n.tr("pulse.common.cancel"), action: onDismiss)
            }
#endif
        }
#if os(iOS) || os(macOS) || os(visionOS)
        .sheet(item: $viewModel.shareItems) {
            ShareView($0).onCompletion(onDismiss)
        }
#endif
#elseif os(macOS)
        Form {
            sectionSharingOptions
            Divider()
            sectionShare.popover(item: $viewModel.shareItems, arrowEdge: .trailing) {
                ShareView($0)
            }
        }
        .listStyle(.sidebar)
        .padding()
        .popover(isPresented: $isShowingLabelPicker, arrowEdge: .trailing) {
            destinationLogLevels.padding()
        }
#endif
    }

    @ViewBuilder
    private var sectionSharingOptions: some View {
        Section {
            ConsoleSessionsPickerView(selection: $viewModel.sessions)
#if os(iOS) || os(visionOS)
            NavigationLink(destination: destinationLogLevels) {
                InfoRow(title: L10n.tr("pulse.filters.levels"), details: viewModel.selectedLevelsTitle)
            }
#else
            HStack {
                Text(L10n.tr("pulse.filters.levels"))
                Spacer()
                Button(action: { isShowingLabelPicker = true }) {
                    Text(viewModel.selectedLevelsTitle + "...")
                }
            }
#endif
        }
        Section {
            Picker(L10n.tr("pulse.share.output"), selection: $viewModel.output) {
                ForEach(viewModel.shareStoreOutputs, id: \.rawValue) { shareOutput in
                    Text(shareOutput.interfaceTitle).tag(shareOutput)
                }
            }
#if os(macOS)
            .labelsHidden()
#endif
        }
    }

    private var destinationLogLevels: some View {
        Form {
            ConsoleSearchLogLevelsCell(selection: $viewModel.logLevels)
        }.inlineNavigationTitle(L10n.tr("pulse.filters.levels"))
    }

#if os(iOS) || os(macOS) || os(visionOS)
    private var sectionShare: some View {
        Section {
            Button(action: { viewModel.buttonSharedTapped() }) {
#if os(iOS) || os(visionOS)
                HStack {
                    Spacer()
                    Text(viewModel.isPreparingForSharing ? L10n.tr("pulse.common.exporting") : L10n.tr("pulse.common.share"))
                        .bold()
                    Spacer()
                }
#else
                Text(viewModel.isPreparingForSharing ? L10n.tr("pulse.common.exporting") : L10n.tr("pulse.common.share"))
#endif
            }
            .disabled(viewModel.isPreparingForSharing)
            .foregroundColor(.white)
#if os(iOS) || os(visionOS)
            .listRowBackground(viewModel.isPreparingForSharing ? Color.accentColor.opacity(0.33) : Color.accentColor)
#endif
        }
    }
#else
    private var sectionShare: some View {
        Section {
            NavigationLink(destination: VStack {
                if let shareItems = viewModel.shareItems {
                    ShareLink(items: shareItems.items as! [URL])
                } else {
                    ProgressView(label: {
                        Text(L10n.tr("pulse.common.exporting"))
                    }).onAppear {
                        viewModel.prepareForSharing()
                    }
                }
            }, label: {
                Text(L10n.tr("pulse.common.share_ellipsis"))
            })
        }
    }
#endif
}

#if DEBUG
@available(iOS 16, macOS 13, watchOS 9, visionOS 1, *)
struct ShareStoreView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS) || os(visionOS)
        NavigationView {
            ShareStoreView(onDismiss: {})
        }
#else
        ShareStoreView(onDismiss: {})
            .frame(width: 240).fixedSize()
#endif
    }
}
#endif

#endif
