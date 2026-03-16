// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

package struct KeyValueSectionViewModel {
    package var title: String
    package var color: Color
    package var items: [(String, String?)] = []

    package init(title: String, color: Color, items: [(String, String?)]) {
        self.title = title
        self.color = color
        self.items = items
    }
}

extension KeyValueSectionViewModel {
    package static func makeParameters(for request: NetworkRequestEntity) -> KeyValueSectionViewModel {
        var items: [(String, String?)] = [
            (L10n.tr("pulse.details.cache_policy"), request.cachePolicy.description),
            (L10n.tr("pulse.details.timeout_interval"), DurationFormatter.string(from: TimeInterval(request.timeoutInterval), isPrecise: false))
        ]
        // Display only non-default values
        if !request.allowsCellularAccess {
            items.append((L10n.tr("pulse.details.allows_cellular_access"), request.allowsCellularAccess.description))
        }
        if !request.allowsExpensiveNetworkAccess {
            items.append((L10n.tr("pulse.details.allows_expensive_network_access"), request.allowsExpensiveNetworkAccess.description))
        }
        if !request.allowsConstrainedNetworkAccess {
            items.append((L10n.tr("pulse.details.allows_constrained_network_access"), request.allowsConstrainedNetworkAccess.description))
        }
        if !request.httpShouldHandleCookies {
            items.append((L10n.tr("pulse.details.should_handle_cookies"), request.httpShouldHandleCookies.description))
        }
        if request.httpShouldUsePipelining {
            items.append((L10n.tr("pulse.details.http_should_use_pipelining"), request.httpShouldUsePipelining.description))
        }
        if #available(iOS 16, *) {
            return KeyValueSectionViewModel(title: L10n.tr("pulse.details.options"), color: .indigo, items: items)
        } else {
            return KeyValueSectionViewModel(title: L10n.tr("pulse.details.options"), color: .purple, items: items)
        }
    }

    package static func makeTaskDetails(for task: NetworkTaskEntity) -> KeyValueSectionViewModel {
        func format(size: Int64) -> String {
            size > 0 ? ByteCountFormatter.string(fromByteCount: size) : "Empty"
        }
        let taskType = task.type?.urlSessionTaskClassName ?? "URLSessionDataTask"
        var items: [(String, String?)] = [
            (L10n.tr("pulse.details.host"), task.url.flatMap(URL.init)?.host),
            (L10n.tr("pulse.details.date"), task.startDate.map(DateFormatter.fullDateFormatter.string))
        ]
        if task.duration > 0 {
            items.append((L10n.tr("pulse.details.duration"), DurationFormatter.string(from: task.duration)))
        }
        if let description = task.taskDescription, !description.isEmpty {
            items.append((L10n.tr("pulse.details.description"), description))
        }
        return KeyValueSectionViewModel(title: taskType, color: .primary, items: items)
    }

    package static func makeComponents(for url: URL) -> KeyValueSectionViewModel? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        return KeyValueSectionViewModel(
            title: L10n.tr("pulse.details.url_components"),
            color: .blue,
            items: [
                (L10n.tr("pulse.details.scheme"), components.scheme),
                (L10n.tr("pulse.details.port"), components.port?.description),
                (L10n.tr("pulse.details.user"), components.user),
                (L10n.tr("pulse.details.password"), components.password),
                (L10n.tr("pulse.details.host"), components.host),
                (L10n.tr("pulse.details.path"), components.path),
                (L10n.tr("pulse.details.query"), components.query),
                (L10n.tr("pulse.details.fragment"), components.fragment)
            ].filter { $0.1?.isEmpty == false })
    }

    package static func makeHeaders(title: String, headers: [String: String]?) -> KeyValueSectionViewModel {
        KeyValueSectionViewModel(
            title: title,
            color: .red,
            items: (headers ?? [:]).sorted {
                // Display cookies last because they typically take too much space
                $1.key.lowercased().contains("cookies") || $0.key < $1.key
            }
        )
    }

    package static func makeErrorDetails(for task: NetworkTaskEntity) -> KeyValueSectionViewModel? {
        guard task.errorCode != 0, task.state == .failure else {
            return nil
        }
        return KeyValueSectionViewModel(
            title: L10n.tr("pulse.details.error"),
            color: .red,
            items: [
                (L10n.tr("pulse.details.domain"), task.errorDomain),
                (L10n.tr("pulse.details.code"), descriptionForError(domain: task.errorDomain, code: task.errorCode)),
                (L10n.tr("pulse.details.description"), task.errorDebugDescription)
            ])
    }

    private static func descriptionForError(domain: String?, code: Int32) -> String {
        guard domain == NSURLErrorDomain else {
            return "\(code)"
        }
        return "\(code) (\(descriptionForURLErrorCode(Int(code))))"
    }

    package static func makeQueryItems(for url: URL) -> KeyValueSectionViewModel? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              !queryItems.isEmpty else {
            return nil
        }
        return makeQueryItems(for: queryItems)
    }

    package static func makeQueryItems(for queryItems: [URLQueryItem]) -> KeyValueSectionViewModel? {
        KeyValueSectionViewModel(
            title: L10n.tr("pulse.details.query"),
            color: .purple,
            items: queryItems.map { ($0.name, $0.value) }
        )
    }

    package static func makeDetails(for transaction: NetworkTransactionMetricsEntity) -> [KeyValueSectionViewModel] {
        return [
            makeTiming(for: transaction),
            makeTransferSection(for: transaction),
            makeProtocolSection(for: transaction),
            makeMiscSection(for: transaction),
            makeSecuritySection(for: transaction)
        ].compactMap { $0 }
    }

    private static func makeTiming(for transaction: NetworkTransactionMetricsEntity) -> KeyValueSectionViewModel {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US")
        timeFormatter.dateFormat = "hh:mm:ss.SSS"

        var startDate: Date?
        var items: [(String, String?)] = []
        func addDate(_ date: Date?, title: String) {
            guard let date = date else { return }
            if items.isEmpty {
                startDate = date
            }
            var value = timeFormatter.string(from: date)
            if let startDate = startDate, startDate != date {
                let duration = date.timeIntervalSince(startDate)
                value += " (+\(DurationFormatter.string(from: duration)))"
            }
            items.append((title, value))
        }
        let timing = transaction.timing
        addDate(timing.fetchStartDate, title: "Fetch Start")
        addDate(timing.domainLookupStartDate, title: "Domain Lookup Start")
        addDate(timing.domainLookupEndDate, title: "Domain Lookup End")
        addDate(timing.connectStartDate, title: "Connect Start")
        addDate(timing.secureConnectionStartDate, title: "Secure Connect Start")
        addDate(timing.secureConnectionEndDate, title: "Secure Connect End")
        addDate(timing.connectEndDate, title: "Connect End")
        addDate(timing.requestStartDate, title: "Request Start")
        addDate(timing.requestEndDate, title: "Request End")
        addDate(timing.responseStartDate, title: "Response Start")
        addDate(timing.responseEndDate, title: "Response End")
#if !os(watchOS)
        let longestTitleCount = items.map(\.0.count).max() ?? 0
        items = items.map {
            ($0.0.padding(toLength: longestTitleCount + 1, withPad: " ", startingAt: 0), $0.1)
        }
#endif
        return KeyValueSectionViewModel(title: L10n.tr("pulse.details.timing"), color: .orange, items: items)
    }

    private static func makeTransferSection(for metrics: NetworkTransactionMetricsEntity) -> KeyValueSectionViewModel? {
        let transferSize = metrics.transferSize
        return KeyValueSectionViewModel(title: L10n.tr("pulse.details.data_transfer"), color: .primary, items: [
            (L10n.tr("pulse.network.request_headers"), formatBytes(transferSize.requestHeaderBytesSent)),
            (L10n.tr("pulse.network.request_body"), formatBytes(transferSize.requestBodyBytesBeforeEncoding)),
            (L10n.tr("pulse.details.request_body_encoded"), formatBytes(transferSize.requestBodyBytesSent)),
            (L10n.tr("pulse.network.response_headers"), formatBytes(transferSize.responseHeaderBytesReceived)),
            (L10n.tr("pulse.network.response_body"), formatBytes(transferSize.responseBodyBytesReceived)),
            (L10n.tr("pulse.details.response_body_decoded"), formatBytes(transferSize.responseBodyBytesAfterDecoding))
        ])
    }

    private static func makeProtocolSection(for metrics: NetworkTransactionMetricsEntity) -> KeyValueSectionViewModel? {
        KeyValueSectionViewModel(title: L10n.tr("pulse.details.protocol"), color: .primary, items: [
            (L10n.tr("pulse.details.network_protocol"), metrics.networkProtocol),
            (L10n.tr("pulse.details.remote_address"), metrics.remoteAddress),
            (L10n.tr("pulse.details.remote_port"), metrics.remotePort > 0 ? String(metrics.remotePort) : nil),
            (L10n.tr("pulse.details.local_address"), metrics.localAddress),
            (L10n.tr("pulse.details.local_port"), metrics.localPort > 0 ? String(metrics.localPort) : nil)
        ])
    }

    private static func makeSecuritySection(for metrics: NetworkTransactionMetricsEntity) -> KeyValueSectionViewModel? {
        guard let suite = metrics.negotiatedTLSCipherSuite,
              let version = metrics.negotiatedTLSProtocolVersion else {
            return nil
        }
        return KeyValueSectionViewModel(title: L10n.tr("pulse.details.security"), color: .primary, items: [
            (L10n.tr("pulse.details.cipher_suite"), suite.description),
            (L10n.tr("pulse.details.protocol_version"), version.description)
        ])
    }

    private static func makeMiscSection(for metrics: NetworkTransactionMetricsEntity) -> KeyValueSectionViewModel? {
        KeyValueSectionViewModel(title: L10n.tr("pulse.details.characteristics"), color: .primary, items: [
            (L10n.tr("pulse.details.cellular"), metrics.isCellular.description),
            (L10n.tr("pulse.details.expensive"), metrics.isExpensive.description),
            (L10n.tr("pulse.details.constrained"), metrics.isConstrained.description),
            (L10n.tr("pulse.details.proxy_connection"), metrics.isProxyConnection.description),
            (L10n.tr("pulse.details.reused_connection"), metrics.isReusedConnection.description),
            (L10n.tr("pulse.details.multipath"), metrics.isMultipath.description)
        ])
    }

    package static func makeDetails(for cookie: HTTPCookie, color: Color) -> KeyValueSectionViewModel {
        KeyValueSectionViewModel(title: cookie.name, color: color, items: [
            (L10n.tr("pulse.details.name"), cookie.name),
            (L10n.tr("pulse.details.value"), cookie.value),
            (L10n.tr("pulse.details.domain"), cookie.domain),
            (L10n.tr("pulse.details.path"), cookie.path),
            (L10n.tr("pulse.details.expires"), cookie.expiresDate?.description(with: Locale(identifier: "en_US"))),
            (L10n.tr("pulse.details.secure"), "\(cookie.isSecure)"),
            (L10n.tr("pulse.details.http_only"), "\(cookie.isHTTPOnly)"),
            (L10n.tr("pulse.details.session_only"), "\(cookie.isSessionOnly)")
        ])
    }
}

private func formatBytes(_ count: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: count)
}
