// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import Foundation
import SwiftUI
import Combine
import Pulse
import Network

@available(iOS 14.0, tvOS 14.0, *)
struct RemoteLoggerSettingsView: View {
    @ObservedObject private var logger: RemoteLogger = .shared
    @ObservedObject var viewModel: RemoteLoggerSettingsViewModel
    
    var body: some View {
        toggleView
        if viewModel.isEnabled {
            if let error = logger.browserError {
                browserErrorView(error)
            } else if !viewModel.servers.isEmpty {
#if os(macOS)
                ForEach(viewModel.servers, content: makeServerView)
#else
                List(viewModel.servers, rowContent: makeServerView)
#endif
            } else {
                progressView
            }
        }
    }

    private var toggleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $viewModel.isEnabled, label: {
                HStack {
#if !os(watchOS)
                    Image(systemName: "network")
#endif
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.tr("pulse.remote.logging"))
#if !os(watchOS)
                        Text(L10n.tr("pulse.remote.requires_pulse_for_mac"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
#endif
                    }
                }
            })

            if let server = logger.selectedServerName {
                selectedServerView(name: server)
            }
        }
    }
    
    private var progressView: some View {
#if os(watchOS)
        ProgressView()
            .progressViewStyle(.circular)
            .frame(idealWidth: .infinity, alignment: .center)
#else
        HStack(spacing: 8) {
#if !os(macOS)
            ProgressView()
                .progressViewStyle(.circular)
#endif
            Text(L10n.tr("pulse.remote.searching"))
                .foregroundColor(.secondary)
        }
#endif
    }
    
    @ViewBuilder
    private func makeServerView(for server: RemoteLoggerServerViewModel) -> some View {
        Button(action: server.connect) {
            HStack {
                if server.isSelected {
                    if viewModel.isConnected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 21, height: 36, alignment: .center)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(width: 21, height: 36, alignment: .leading)
                    }
                } else {
                    Rectangle()
                        .hidden()
                        .frame(width: 21, height: 36, alignment: .center)
                }
                Text(server.name)
                    .lineLimit(1)
                if server.isProtected {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }.foregroundColor(Color.primary)
            .frame(maxWidth: .infinity)
    }

    private func selectedServerView(name: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(connectionStatusColor)
                    Text(connectionStatusText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: {
                logger.forgetServer(named: name)
                viewModel.refreshServers()
            }, label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            })
#if os(tvOS)
            .buttonStyle(.plain)
#endif
        }
    }

    private var connectionStatusColor: Color {
        switch logger.connectionState {
        case .connected: return .green
        case .connecting: return .yellow
        case .idle: return .gray
        }
    }

    private var connectionStatusText: String {
        switch logger.connectionState {
        case .connected: return L10n.tr("pulse.remote.connected")
        case .connecting: return L10n.tr("pulse.remote.connecting")
        case .idle: return L10n.tr("pulse.remote.disconnected")
        }
    }

    private func browserErrorView(_ error: NWError) -> some View {
        switch error {
        case .dns(let error):
            switch Int(error) {
            case kDNSServiceErr_NoAuth:
                return AnyView(remoteLoggerNoAuthView)
            case kDNSServiceErr_PolicyDenied:
                return AnyView(remoteLoggerPolicyDeniedView)
            default:
                return AnyView(genericBrowserErrorDescription(String(describing: error)))
            }
        default:
            return AnyView(genericBrowserErrorView(error))
        }
    }

    private func genericBrowserErrorView(_ error: NWError) -> some View {
        genericBrowserErrorDescription(error.localizedDescription)
    }

    private func genericBrowserErrorDescription(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("pulse.remote.devices_browser_failed"))
                .font(.headline)
            Text(description)
                .font(.subheadline)
        }
    }

    private var remoteLoggerPolicyDeniedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("pulse.remote.local_network_denied"))
                .font(.headline)
            Text(L10n.tr("pulse.remote.local_network_denied_help"))
                .font(.subheadline)
#if os(iOS)
            Button(L10n.tr("pulse.remote.open_settings")) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
#endif
        }
    }

    private var remoteLoggerNoAuthView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("pulse.remote.info_plist_misconfigured"))
                .font(.headline)
            Text(L10n.tr("pulse.remote.info_plist_help"))
                .font(.subheadline)

            Text(remoteLoggerPlistContents)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.12))
                .cornerRadius(4)
#if os(iOS)
            Button(L10n.tr("pulse.remote.copy_contents")) {
                UIPasteboard.general.string = remoteLoggerPlistContents
            }
#endif
        }
    }
}

@available(iOS 14.0, tvOS 14.0, *)
final class RemoteLoggerSettingsViewModel: ObservableObject {
    @Published var isEnabled: Bool = false
    @Published var servers: [RemoteLoggerServerViewModel] = []
    @Published var isConnected: Bool = false
    
    private let logger: RemoteLogger
    private var cancellables: [AnyCancellable] = []
    
    public static var shared = RemoteLoggerSettingsViewModel()
    
    init(logger: RemoteLogger = .shared) {
        self.logger = logger
        
        isEnabled = logger.isEnabled
        
        $isEnabled.removeDuplicates().receive(on: DispatchQueue.main)
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] in
                self?.didUpdateIsEnabled($0)
            }.store(in: &cancellables)
        
        logger.$servers.receive(on: DispatchQueue.main).sink { [weak self] servers in
            self?.refresh(servers: servers)
        }.store(in: &cancellables)
        
        logger.$connectionState.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.isConnected = $0 == .connected
        }.store(in: &cancellables)
    }
    
    private func didUpdateIsEnabled(_ isEnabled: Bool) {
        isEnabled ? logger.enable() : logger.disable()
    }
    
    private func refresh(servers: Set<NWBrowser.Result>) {
        self.servers = servers
            .map { server in
                RemoteLoggerServerViewModel(
                    id: server,
                    name: server.name ?? "–",
                    isSelected: logger.isSelected(server),
                    isProtected: server.isProtected,
                    connect: { [weak self] in self?.connect(to: server) }
                )
            }
            .sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func refreshServers() {
        refresh(servers: logger.servers)
    }
    
    private func connect(to server: NWBrowser.Result) {
        logger.connect(to: server)
        refresh(servers: logger.servers)
    }
}

struct RemoteLoggerServerViewModel: Identifiable {
    let id: AnyHashable
    let name: String
    let isSelected: Bool
    let isProtected: Bool
    let connect: () -> Void
}

@available(iOS 14.0, tvOS 14.0, *)
private extension NWBrowser.Result {
    var name: String? {
        switch endpoint {
        case .service(let name, _, _, _):
            return name
        default:
            return nil
        }
    }

    var isProtected: Bool {
        switch metadata {
        case .bonjour(let record):
            return record["protected"].map { Bool($0) } == true
        case .none:
            return false
        @unknown default:
            return false
        }
    }
}

#if DEBUG
struct RemoteLoggerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, tvOS 14.0, *) {
            RemoteLoggerSettingsView(viewModel: .shared)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

private let remoteLoggerPlistContents = """
<key>NSLocalNetworkUsageDescription</key>
<string>Debugging purposes</string>
<key>NSBonjourServices</key>
<array>
  <string>_pulse._tcp</string>
</array>
"""
