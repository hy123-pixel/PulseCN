// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(tvOS)

import SwiftUI
import Pulse

public struct SettingsView: View {
    private let store: LoggerStore

    public init(store: LoggerStore = .shared) {
        self.store = store
    }

    public var body: some View {
        Form {
            if !UserSettings.shared.isRemoteLoggingHidden,
                store === RemoteLogger.shared.store {
                RemoteLoggerSettingsView(viewModel: .shared)
            }
            Section {
                if #available(tvOS 16, *) {
                    NavigationLink(destination: StoreDetailsView(source: .store(store))) {
                        Text(L10n.tr("pulse.settings.store_info"))
                    }
                }
                if !store.options.contains(.readonly) {
                    Button(role: .destructive, action: { store.removeAll() }) {
                        Text(L10n.tr("pulse.store.remove_logs"))
                    }
                }
            }
        }
        .navigationTitle(L10n.tr("pulse.common.settings"))
        .frame(maxWidth: 800)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(store: .mock)
        }.navigationViewStyle(.stack)
    }
}
#endif
#endif
