// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse
import SwiftUI
import CoreData
import Combine

#if os(iOS) || os(visionOS)

@available(iOS 16, visionOS 1, *)
struct SessionsView: View {
    @State private var selection: Set<UUID> = []
    @State private var sharedSessions: SelectedSessionsIDs?
    @State private var editMode: EditMode = .inactive

    @EnvironmentObject private var environment: ConsoleEnvironment
    @EnvironmentObject private var filters: ConsoleFiltersViewModel
    @Environment(\.store) private var store
    @Environment(\.router) private var router

    var body: some View {
        if store.version < LoggerStore.Version(3, 6, 0) {
            PlaceholderView(imageName: "questionmark.app", title: L10n.tr("pulse.common.unsupported"), subtitle: L10n.tr("pulse.sessions.version_required")).padding()
        } else {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        list
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editMode.isEditing ? L10n.tr("pulse.common.done" ) : L10n.tr("pulse.common.edit")) {
                        withAnimation {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if editMode == .active {
                        bottomBar
                    }
                }
            }
            .sheet(item: $sharedSessions) { sessions in
                NavigationView {
                    ShareStoreView(sessions: sessions.ids, onDismiss: { sharedSessions = nil })
                }.presentationDetents([.medium, .large])
            }
    }

    private var list: some View {
        SessionListView(selection: $selection, sharedSessions: $sharedSessions)
            .environment(\.editMode, $editMode)
            .onChange(of: selection) {
                guard !editMode.isEditing, !$0.isEmpty else { return }
                showInConsole(sessions: $0)
            }
    }

#if os(iOS) || os(visionOS)
    var bottomBar: some View {
        HStack {
            Button(role: .destructive, action: {
                store.removeSessions(withIDs: selection)
                selection = []
            }, label: { Image(systemName: "trash") })
            .disabled(selection.isEmpty || selection == [store.session.id])

            Spacer()

            // It should ideally be done using stringsdict, but Pulse
            // doesn't support localization.
            if selection.count % 10 == 1 {
                Text(L10n.fmt("pulse.sessions.session_selected", selection.count))
            } else {
                Text(L10n.fmt("pulse.sessions.sessions_selected", selection.count))
            }

            Spacer()

            Button(action: { sharedSessions = SelectedSessionsIDs(ids: selection) }, label: {
                Image(systemName: "square.and.arrow.up")
            })
            .disabled(selection.isEmpty)

            Menu(content: {
                Button(L10n.tr("pulse.sessions.show_in_console")) {
                    showInConsole(sessions: selection)
                }.disabled(selection.isEmpty)
            }, label: {
                Image(systemName: "ellipsis.circle")
            })
        }
    }

    private func showInConsole(sessions: Set<UUID>) {
        filters.select(sessions: sessions)
        router.isShowingSessions = false
    }
#endif
}

#if DEBUG
@available(iOS 16, visionOS 1, *)
struct Previews_SessionsView_Previews: PreviewProvider {
    static let environment = ConsoleEnvironment(store: .mock)

    static var previews: some View {
        NavigationView {
            SessionsView()
                .injecting(environment)
        }
    }
}
#endif

#endif
