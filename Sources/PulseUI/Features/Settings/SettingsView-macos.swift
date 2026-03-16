// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

#if os(macOS)
import UniformTypeIdentifiers

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    var store: LoggerStore { viewModel.store }

    @State private var isDocumentBrowserPresented = false

    public init(store: LoggerStore = .shared) {
        self.viewModel = SettingsViewModel(store: store)
    }

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            List {
                HStack {
                    Text(L10n.tr("pulse.common.settings"))
                        .font(.title)
                    Spacer()
                    Button(L10n.tr("pulse.common.close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                Section(header: Text(L10n.tr("pulse.store.open_store"))) {
                    Button(L10n.tr("pulse.store.open_in_finder")) {
                        NSWorkspace.shared.activateFileViewerSelecting([store.storeURL])
                    }
                    Button(L10n.tr("pulse.store.open_in_pulse_pro")) {
                        NSWorkspace.shared.open(store.storeURL)
                    }
                }
                Section(header: Text(L10n.tr("pulse.settings.manage_messages"))) {
                    if !viewModel.isArchive {
                        ButtonRemoveAll(action: viewModel.buttonRemoveAllMessagesTapped)
                    }
                }
                Section(header: Text(L10n.tr("pulse.remote.logging"))) {
                    if viewModel.isRemoteLoggingAvailable {
                        RemoteLoggerSettingsView(viewModel: .shared)
                    } else {
                        Text(L10n.tr("pulse.common.not_available"))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(width: 260, height: 400)
    }
}

// MARK: - Preview

#if DEBUG
struct ConsoleSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(store: .shared))
    }
}
#endif
#endif
