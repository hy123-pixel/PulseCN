// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse

struct ConsoleListOptions: Equatable {
    var messageSortBy: MessageSortBy = .dateCreated
    var taskSortBy: TaskSortBy = .dateCreated
    var order: Ordering = .descending

    enum Ordering: String, CaseIterable {
        case descending = "Descending"
        case ascending = "Ascending"

        var title: String {
            switch self {
            case .descending: return L10n.tr("pulse.console.descending")
            case .ascending: return L10n.tr("pulse.console.ascending")
            }
        }
    }

    enum MessageSortBy: String, CaseIterable {
        case dateCreated = "Date"
        case level = "Level"

        var title: String {
            switch self {
            case .dateCreated: return L10n.tr("pulse.details.date")
            case .level: return L10n.tr("pulse.message.level")
            }
        }

        var key: String {
            switch self {
            case .dateCreated: return "createdAt"
            case .level: return "level"
            }
        }
    }

    enum TaskSortBy: String, CaseIterable {
        case dateCreated = "Date"
        case duration = "Duration"
        case requestSize = "Request Size"
        case responseSize = "Response Size"

        var title: String {
            switch self {
            case .dateCreated: return L10n.tr("pulse.details.date")
            case .duration: return L10n.tr("pulse.details.duration")
            case .requestSize: return L10n.tr("pulse.details.request_size")
            case .responseSize: return L10n.tr("pulse.details.response_size")
            }
        }

        var key: String {
            switch self {
            case .dateCreated: return "createdAt"
            case .duration: return "duration"
            case .requestSize: return "requestBodySize"
            case .responseSize: return "responseBodySize"
            }
        }
    }
}
