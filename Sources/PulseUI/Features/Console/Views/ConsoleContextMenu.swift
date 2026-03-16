// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(visionOS)

import SwiftUI
import CoreData
import Pulse
import Combine

@available(iOS 16, visionOS 1, *)
struct ConsoleContextMenu: View {
    @EnvironmentObject private var environment: ConsoleEnvironment
    @Environment(\.router) private var router

    var body: some View {
        Menu {
            Section {
                Button(action: { router.isShowingSessions = true }) {
                    Label(L10n.tr("pulse.console.sessions.title"), systemImage: "list.bullet.clipboard")
                }
            }
            Section {
                ConsoleSortByMenu()
            }
            Section {
                if !UserDefaults.standard.bool(forKey: "pulse-disable-settings-prompts") {
                    Button(action: { router.isShowingSettings = true }) {
                        Label(L10n.tr("pulse.common.settings"), systemImage: "gear")
                    }
                }
                
                if !environment.store.options.contains(.readonly) {
                    Button(role: .destructive, action: environment.removeAllLogs) {
                        Label(L10n.tr("pulse.store.remove_logs"), systemImage: "trash")
                    }
                }
            }
            Section {
                if !UserDefaults.standard.bool(forKey: "pulse-disable-support-prompts") {
                    Button(action: buttonGetPulseProTapped) {
                        Label(L10n.tr("pulse.console.get_pulse_pro"), systemImage: "link")
                    }
                }
                if !UserDefaults.standard.bool(forKey: "pulse-disable-report-issue-prompts") {
                    Button(action: buttonSendFeedbackTapped) {
                        Label(L10n.tr("pulse.console.report_issue"), systemImage: "envelope")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    private func buttonGetPulseProTapped() {
        URL(string: "https://pulselogger.com").map(openURL)
    }

    private func buttonSendFeedbackTapped() {
        URL(string: "https://github.com/kean/Pulse/issues").map(openURL)
    }

    private func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

private struct ConsoleSortByMenu: View {
    @EnvironmentObject private var environment: ConsoleEnvironment

    var body: some View {
        Menu(content: {
            if environment.mode == .network {
                Picker(L10n.tr("pulse.console.sort_by"), selection: $environment.listOptions.taskSortBy) {
                    ForEach(ConsoleListOptions.TaskSortBy.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
            } else {
                Picker(L10n.tr("pulse.console.sort_by"), selection: $environment.listOptions.messageSortBy) {
                    ForEach(ConsoleListOptions.MessageSortBy.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
            }
            Picker(L10n.tr("pulse.console.ordering"), selection: $environment.listOptions.order) {
                Text(L10n.tr("pulse.console.descending")).tag(ConsoleListOptions.Ordering.descending)
                Text(L10n.tr("pulse.console.ascending")).tag(ConsoleListOptions.Ordering.ascending)
            }
        }, label: {
            Label(L10n.tr("pulse.console.sort_by"), systemImage: "arrow.up.arrow.down")
        })
    }
}
#endif
