// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Network

@available(iOS 16, visionOS 1, *)
struct RemoteLoggerErrorView: View {
    let error: NWError

    var body: some View {
        switch error {
        case .dns(let error):
            switch Int(error) {
            case kDNSServiceErr_NoAuth:
                RemoteLoggerNoAuthView()
            case kDNSServiceErr_PolicyDenied:
                RemoteLoggerPolicyDeniedView()
            default:
                RemoteLoggerPolicyGenericErrorView(error: self.error)
            }
        default:
            RemoteLoggerPolicyGenericErrorView(error: error)
        }
    }
}

private struct RemoteLoggerPolicyGenericErrorView: View {
    let error: NWError

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("pulse.remote.devices_browser_failed"))
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
        }
    }
}

private struct RemoteLoggerPolicyDeniedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("pulse.remote.local_network_denied"))
                .font(.headline)
            Text(L10n.tr("pulse.remote.local_network_denied_help"))
                .font(.subheadline)
        }
#if os(iOS) || os(visionOS)
        Button(L10n.tr("pulse.remote.open_settings")) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
#endif
    }
}

@available(iOS 16, visionOS 1, *)
private struct RemoteLoggerNoAuthView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("pulse.remote.info_plist_misconfigured"))
                .font(.headline)
            Text(L10n.tr("pulse.remote.info_plist_help"))
                .font(.subheadline)

            Text(plistContents)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color.separator.opacity(0.2))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.separator, lineWidth: 0.5)
                )
                .padding(.top, 8)
        }
#if os(iOS) || os(visionOS)
        Button(L10n.tr("pulse.remote.copy_contents")) {
            UXPasteboard.general.string = plistContents
        }
#endif
    }
}

private let plistContents = """
<key>NSLocalNetworkUsageDescription</key>
<string>Debugging purposes</string>
<key>NSBonjourServices</key>
<array>
  <string>_pulse._tcp</string>
</array>
"""

#if DEBUG
@available(iOS 16, visionOS 1, *)
struct Previews_RemoteLoggerNoAuthView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section {
                RemoteLoggerPolicyDeniedView()
            }
            Section {
                RemoteLoggerNoAuthView()
            }
        }
    }
}
#endif
