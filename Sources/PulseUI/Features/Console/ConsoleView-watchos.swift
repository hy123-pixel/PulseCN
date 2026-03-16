// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

#if os(watchOS)

import SwiftUI

struct ConsoleView: View {
    @ObservedObject var viewModel: ConsoleViewModel
    let main: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel.console
        self.main = viewModel
    }

    var body: some View {
        List {
            NavigationLink(destination: SettingsView(viewModel: main.settings)) {
                Label(L10n.tr("pulse.common.settings"), systemImage: "gearshape")
            }

            Button(action: { viewModel.isOnlyErrors.toggle() }) {
                Label(L10n.tr("pulse.console.show_errors"), systemImage: viewModel.isOnlyErrors ? "exclamationmark.octagon.fill" : "exclamationmark.octagon")
            }
            .listRowBackground(viewModel.isOnlyErrors ? Color.blue.cornerRadius(8) : nil)

            Button(action: { viewModel.isOnlyNetwork.toggle() }) {
                Label(L10n.tr("pulse.console.show_requests"), systemImage: "network")
            }
            .listRowBackground(viewModel.isOnlyNetwork ? Color.blue.cornerRadius(8) : nil)

            ConsoleMessagesForEach(messages: viewModel.entities)
        }
        .navigationTitle(L10n.tr("pulse.console.title"))
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
    }
}

#if DEBUG
struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsoleView(viewModel: .init(store: .mock, onDismiss: nil))
        }
    }
}
#endif

#endif
