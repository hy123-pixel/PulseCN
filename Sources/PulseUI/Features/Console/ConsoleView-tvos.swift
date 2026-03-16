// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(tvOS)

import SwiftUI
import CoreData
import Pulse
import Combine

public struct ConsoleView: View {
    @StateObject private var environment: ConsoleEnvironment
    @StateObject private var listViewModel: ConsoleListViewModel

    init(environment: ConsoleEnvironment) {
        _environment = StateObject(wrappedValue: environment)
        _listViewModel = StateObject(wrappedValue: .init(environment: environment, filters: environment.filters))
    }

    public var body: some View {
        GeometryReader { _ in
            HStack {
                List {
                    ConsoleListContentView()
                }

                // TODO: Not sure it's valid
                NavigationView {
                    Form {
                        ConsoleMenuView()
                    }.padding()
                }
                .frame(width: 700)
            }
            .navigationTitle(environment.title)
            .onAppear { listViewModel.isViewVisible = true }
            .onDisappear { listViewModel.isViewVisible = false }
        }
        .disableScrollClip()
        .injecting(environment)
        .environmentObject(listViewModel)
    }
}

private struct ConsoleMenuView: View {
    @EnvironmentObject private var viewModel: ConsoleFiltersViewModel
    @EnvironmentObject private var environment: ConsoleEnvironment
    @Environment(\.store) private var store

    var body: some View {
        Section {
            Toggle(isOn: $viewModel.options.isOnlyErrors) {
                Label(L10n.tr("pulse.console.errors_only"), systemImage: "exclamationmark.octagon")
            }
            Toggle(isOn: environment.bindingForNetworkMode) {
                Label(L10n.tr("pulse.console.network_only"), systemImage: "arrow.down.circle")
            }
            NavigationLink(destination: destinationFilters) {
                Label(environment.bindingForNetworkMode.wrappedValue ? L10n.tr("pulse.console.network_filters") : L10n.tr("pulse.console.message_filters"), systemImage: "line.3.horizontal.decrease.circle")
            }
        } header: { Text(L10n.tr("pulse.filters.quick_filters")) }
        if !(store.options.contains(.readonly)) {
            Section {
                if #available(iOS 16, tvOS 16, *) {
                    NavigationLink {
                        StoreDetailsView(source: .store(store)).padding()
                    } label: {
                        Label(L10n.tr("pulse.settings.store_info"), systemImage: "info.circle")
                    }
                }
                Button(role: .destructive, action: {
                    environment.index.clear()
                    store.removeAll()
                }, label: {
                    Label(L10n.tr("pulse.store.remove_logs"), systemImage: "trash")
                })
            } header: { Text(L10n.tr("pulse.store.title")) }
        }
        Section {
            NavigationLink(destination: destinationSettings) {
                Label(L10n.tr("pulse.common.settings"), systemImage: "gear")
            }
        } header: { Text(L10n.tr("pulse.common.settings")) }
    }

    private var destinationSettings: some View {
        SettingsView(store: store).padding()
    }

    private var destinationFilters: some View {
        ConsoleFiltersView().padding()
    }
}

extension View {
    @available(tvOS, obsoleted: 17.0, renamed: "scrollClipDisabled")
    @ViewBuilder func disableScrollClip() -> some View {
        if #available(tvOS 17.0, *) {
            scrollClipDisabled()
        } else {
            self
        }
    }
}

#if DEBUG
struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsoleView(store: .mock)
        }
    }
}
#endif
#endif
