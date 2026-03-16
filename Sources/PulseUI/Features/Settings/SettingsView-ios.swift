// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(visionOS)

import SwiftUI
import Pulse
import UniformTypeIdentifiers

@available(iOS 16, visionOS 1, *)
public struct SettingsView: View {
    private let store: LoggerStore
    @State private var newHeaderName = ""
    @EnvironmentObject private var settings: UserSettings
    @ObservedObject private var logger: RemoteLogger = .shared

    public init(store: LoggerStore = .shared) {
        self.store = store
    }

    public var body: some View {
        Form {
            if !UserSettings.shared.isRemoteLoggingHidden,
               store === RemoteLogger.shared.store {
                RemoteLoggerSettingsView(viewModel: .shared)
            }
            Section(L10n.tr("pulse.settings.other")) {
                NavigationLink(destination: StoreDetailsView(source: .store(store)), label: {
                    Text(L10n.tr("pulse.settings.store_info"))
                })
            }
        }
        .animation(.default, value: logger.selectedServerName)
        .animation(.default, value: logger.servers)
    }
}

#if DEBUG
@available(iOS 16, visionOS 1, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(store: .mock)
                .environmentObject(UserSettings.shared)
                .injecting(ConsoleEnvironment(store: .mock))
                .navigationTitle(L10n.tr("pulse.common.settings"))
        }
    }
}
#endif

#endif
