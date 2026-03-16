// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import Foundation

enum L10n {
    static func tr(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }
}
