// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import Foundation

extension LoggerStore {
    /// The store info.
    public struct Info: Codable, Sendable {
        // MARK: Store Info

        /// The id of the store.
        ///
        /// - note: If you create a copy of the store for exporting, the copy
        /// gets its own unique ID.
        public var storeId: UUID

        /// The internal version of the store.
        public var storeVersion: String

        // MARK: Creation Dates

        /// The date the store was originally created.
        public var creationDate: Date
        /// The date the store was last modified.
        public var modifiedDate: Date

        // MARK: Usage Statistics

        /// The numbers of recorded messages.
        ///
        /// - note: This excludes the technical messages associated with the
        /// network requests.
        public var messageCount: Int
        /// The number of recorded network requests.
        public var taskCount: Int
        /// The number of stored network response and requests bodies.
        public var blobCount: Int
        /// The complete size of the store, including the database and all
        /// externally stored blobs.
        public var totalStoreSize: Int64
        /// The size of stored network response and requests bodies.
        public var blobsSize: Int64
        /// The size of compressed stored network response and requests bodies.
        /// The blobs are compressed by default.
        public var blobsDecompressedSize: Int64

        // MARK: App and Device Info

        /// Information about the app which created the store.
        public var appInfo: AppInfo
        /// Information about the device which created the store.
        public var deviceInfo: DeviceInfo

        public struct AppInfo: Codable, Sendable {
            public let bundleIdentifier: String?
            public let name: String?
            public let version: String?
            public let build: String?
            /// Base64-encoded app icon (32x32 pixels). Added in 3.5.7
            public let icon: String?
        }

        public struct DeviceInfo: Codable, Sendable {
            public let name: String
            public let model: String
            public let localizedModel: String
            public let systemName: String
            public let systemVersion: String
        }
    }
}

enum AppInfo {
    static var bundleIdentifier: String? { Bundle.main.bundleIdentifier }
    static var appName: String? { Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String }
    static var appVersion: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
    static var appBuild: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }
}

extension LoggerStore.Info.AppInfo {
    static let current = LoggerStore.Info.AppInfo(
        bundleIdentifier: AppInfo.bundleIdentifier,
        name: AppInfo.appName,
        version: AppInfo.appVersion,
        build: AppInfo.appBuild,
        icon: getAppIcon()?.base64EncodedString()
    )
}

private func getAppIcon() -> Data? {
    guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
          let primaryIcons = icons["CFBundlePrimaryIcon"] as? [String: Any],
          let files = primaryIcons["CFBundleIconFiles"] as? [String],
          let lastIcon = files.last,
          let image = PlatformImage(named: lastIcon),
          let thumbnail = Graphics.resize(image, to: CGSize(width: 44, height: 44)) else { return nil }
    return Graphics.encode(thumbnail, compressionQuality: 0.9)
}

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

@MainActor
func getDeviceId() -> UUID? {
    UIDevice.current.identifierForVendor
}

extension LoggerStore.Info.DeviceInfo {
    @MainActor
    static let current: LoggerStore.Info.DeviceInfo = {
        let device = UIDevice.current
        let hardwareIdentifier = currentHardwareIdentifier()
        return LoggerStore.Info.DeviceInfo(
            name: device.name,
            model: hardwareIdentifier,
            localizedModel: marketingName(for: hardwareIdentifier, localizedModel: device.localizedModel) ?? device.localizedModel,
            systemName: device.systemName,
            systemVersion: device.systemVersion
        )
    }()
}

private func currentHardwareIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafePointer(to: &systemInfo.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            String(cString: $0)
        }
    }
}

private func marketingName(for identifier: String, localizedModel: String) -> String? {
    let resolvedIdentifier: String
    if ["i386", "x86_64", "arm64"].contains(identifier) {
        resolvedIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? identifier
    } else {
        resolvedIdentifier = identifier
    }

    switch resolvedIdentifier {
    case "iPhone8,4": return "iPhone SE"
    case "iPhone10,1", "iPhone10,4": return "iPhone 8"
    case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6": return "iPhone X"
    case "iPhone11,2": return "iPhone XS"
    case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
    case "iPhone11,8": return "iPhone XR"
    case "iPhone12,1": return "iPhone 11"
    case "iPhone12,3": return "iPhone 11 Pro"
    case "iPhone12,5": return "iPhone 11 Pro Max"
    case "iPhone12,8": return "iPhone SE (2nd generation)"
    case "iPhone13,1": return "iPhone 12 mini"
    case "iPhone13,2": return "iPhone 12"
    case "iPhone13,3": return "iPhone 12 Pro"
    case "iPhone13,4": return "iPhone 12 Pro Max"
    case "iPhone14,4": return "iPhone 13 mini"
    case "iPhone14,5": return "iPhone 13"
    case "iPhone14,2": return "iPhone 13 Pro"
    case "iPhone14,3": return "iPhone 13 Pro Max"
    case "iPhone14,6": return "iPhone SE (3rd generation)"
    case "iPhone14,7": return "iPhone 14"
    case "iPhone14,8": return "iPhone 14 Plus"
    case "iPhone15,2": return "iPhone 14 Pro"
    case "iPhone15,3": return "iPhone 14 Pro Max"
    case "iPhone15,4": return "iPhone 15"
    case "iPhone15,5": return "iPhone 15 Plus"
    case "iPhone16,1": return "iPhone 15 Pro"
    case "iPhone16,2": return "iPhone 15 Pro Max"
    case "iPhone17,1": return "iPhone 16 Pro"
    case "iPhone17,2": return "iPhone 16 Pro Max"
    case "iPhone17,3": return "iPhone 16"
    case "iPhone17,4": return "iPhone 16 Plus"
    case "iPhone17,5": return "iPhone 16e"
    case "iPhone18,1": return "iPhone 17 Pro"
    case "iPhone18,2": return "iPhone 17 Pro Max"
    case "iPhone18,3": return "iPhone 17"
    case "iPhone18,4": return "iPhone Air"
    case "iPhone18,5": return "iPhone 17e"

    case "iPad13,18", "iPad13,19": return "iPad (10th generation)"
    case "iPad15,7", "iPad15,8": return "iPad (A16)"
    case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"
    case "iPad14,8", "iPad14,9": return "iPad Air 11-inch (M2)"
    case "iPad14,10", "iPad14,11": return "iPad Air 13-inch (M2)"
    case "iPad15,3", "iPad15,4": return "iPad Air 11-inch (M3)"
    case "iPad15,5", "iPad15,6": return "iPad Air 13-inch (M3)"
    case "iPad16,8", "iPad16,9": return "iPad Air 11-inch (M4)"
    case "iPad16,10", "iPad16,11": return "iPad Air 13-inch (M4)"
    case "iPad14,1", "iPad14,2": return "iPad mini (6th generation)"
    case "iPad16,1", "iPad16,2": return "iPad mini (A17 Pro)"
    case "iPad14,3", "iPad14,4": return "iPad Pro 11-inch (4th generation)"
    case "iPad14,5", "iPad14,6": return "iPad Pro 12.9-inch (6th generation)"
    case "iPad16,3", "iPad16,4": return "iPad Pro 11-inch (M4)"
    case "iPad16,5", "iPad16,6": return "iPad Pro 13-inch (M4)"
    case "iPad17,1", "iPad17,2": return "iPad Pro 11-inch (M5)"
    case "iPad17,3", "iPad17,4": return "iPad Pro 13-inch (M5)"

    case "AppleTV14,1": return "Apple TV 4K (3rd generation)"
    case "AppleTV11,1": return "Apple TV 4K (2nd generation)"
    case "AppleTV6,2": return "Apple TV 4K"

    case "Watch7,5": return "Apple Watch Ultra 2"
    case "Watch7,12": return "Apple Watch Ultra 3"
    case "Watch7,1", "Watch7,3": return "Apple Watch Series 9"
    case "Watch7,2", "Watch7,4": return "Apple Watch Series 9"
    case "Watch7,8", "Watch7,10": return "Apple Watch Series 10"
    case "Watch7,9", "Watch7,11": return "Apple Watch Series 10"

    default:
        return localizedModel.isEmpty ? nil : localizedModel
    }
}
#elseif os(watchOS)
import WatchKit

@MainActor
func getDeviceId() -> UUID? {
    WKInterfaceDevice.current().identifierForVendor
}

extension LoggerStore.Info.DeviceInfo {
    @MainActor
    static let current: LoggerStore.Info.DeviceInfo = {
        let device = WKInterfaceDevice.current()
        return LoggerStore.Info.DeviceInfo(
            name: device.name,
            model: device.model,
            localizedModel: device.localizedModel,
            systemName: device.systemName,
            systemVersion: device.systemVersion
        )
    }()
}
#else
import AppKit

extension LoggerStore.Info.DeviceInfo {
    @MainActor
    static let current: LoggerStore.Info.DeviceInfo = {
        return LoggerStore.Info.DeviceInfo(
            name: Host.current().name ?? "unknown",
            model: "unknown",
            localizedModel: "unknown",
            systemName: "macOS",
            systemVersion: ProcessInfo().operatingSystemVersionString
        )
    }()
}

@MainActor
func getDeviceId() -> UUID? {
    return nil
}

#endif
