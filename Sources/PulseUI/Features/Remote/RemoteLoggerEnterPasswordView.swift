// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Network
import Pulse
import Combine

@available(iOS 16, visionOS 1, *)
struct RemoteLoggerEnterPasswordView: View {
    @ObservedObject var viewModel: RemoteLoggerSettingsViewModel
    @ObservedObject var logger: RemoteLogger = .shared

    let server: RemoteLoggerServerViewModel

    @State private var passcode = ""

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        Form {
            Section(content: {
                SecureField(L10n.tr("pulse.remote.password"), text: $passcode)
                    .focused($isTextFieldFocused)
                    .submitLabel(.continue)
                    .onSubmit {
                        connect()
                    }
            }, footer: {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.fmt("pulse.remote.enter_password_for", server.name))
                }
            })
        }
        .inlineNavigationTitle(L10n.tr("pulse.remote.enter_password"))
#if os(iOS) || os(visionOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(L10n.tr("pulse.common.cancel"), role: .cancel) {
                    viewModel.pendingPasscodeProtectedServer = nil
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.tr("pulse.remote.connect")) {
                    connect()
                }
            }
        }
#endif
        .onAppear {
            isTextFieldFocused = true
        }
    }

    private func connect() {
        viewModel.pendingPasscodeProtectedServer = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            viewModel.connect(to: server, passcode: passcode)
        }
    }
}
