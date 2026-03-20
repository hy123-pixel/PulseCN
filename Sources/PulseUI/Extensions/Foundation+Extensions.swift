// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import Foundation
import CommonCrypto
import CoreData
import Combine

extension Character {
    package init?(_ code: unichar) {
        guard let scalar = UnicodeScalar(code) else {
            return nil
        }
        self = Character(scalar)
    }
}

@available(iOS 16, visionOS 1, *)
extension AttributedString {
    package init(_ string: String, _ configure: (inout AttributeContainer) -> Void) {
        var attributes = AttributeContainer()
        configure(&attributes)
        self.init(string, attributes: attributes)
    }

    package mutating func append(_ string: String, _ configure: (inout AttributeContainer) -> Void) {
        var attributes = AttributeContainer()
        configure(&attributes)
        self.append(AttributedString(string, attributes: attributes))
    }
}

extension NSManagedObject {
    package func reset() {
        managedObjectContext?.refresh(self, mergeChanges: false)
    }
}

extension NSManagedObjectContext {
    package func getDistinctValues(entityName: String, property: String) -> Set<String> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = [property]
        guard let results = try? fetch(request) as? [[String: String]] else {
            return []
        }
        return Set(results.flatMap { $0.values })
    }
}

extension tls_ciphersuite_t {
    package var description: String {
        switch self {
        case .RSA_WITH_3DES_EDE_CBC_SHA: return "RSA_WITH_3DES_EDE_CBC_SHA"
        case .RSA_WITH_AES_128_CBC_SHA: return "RSA_WITH_AES_128_CBC_SHA"
        case .RSA_WITH_AES_256_CBC_SHA: return "RSA_WITH_AES_256_CBC_SHA"
        case .RSA_WITH_AES_128_GCM_SHA256: return "RSA_WITH_AES_128_GCM_SHA256"
        case .RSA_WITH_AES_256_GCM_SHA384: return "RSA_WITH_AES_256_GCM_SHA384"
        case .RSA_WITH_AES_128_CBC_SHA256: return "RSA_WITH_AES_128_CBC_SHA256"
        case .RSA_WITH_AES_256_CBC_SHA256: return "RSA_WITH_AES_256_CBC_SHA256"
        case .ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA: return "ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA"
        case .ECDHE_ECDSA_WITH_AES_128_CBC_SHA: return "ECDHE_ECDSA_WITH_AES_128_CBC_SHA"
        case .ECDHE_ECDSA_WITH_AES_256_CBC_SHA: return "ECDHE_ECDSA_WITH_AES_256_CBC_SHA"
        case .ECDHE_RSA_WITH_3DES_EDE_CBC_SHA: return "ECDHE_RSA_WITH_3DES_EDE_CBC_SHA"
        case .ECDHE_RSA_WITH_AES_128_CBC_SHA: return "ECDHE_RSA_WITH_AES_128_CBC_SHA"
        case .ECDHE_RSA_WITH_AES_256_CBC_SHA: return "ECDHE_RSA_WITH_AES_256_CBC_SHA"
        case .ECDHE_ECDSA_WITH_AES_128_CBC_SHA256: return "ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
        case .ECDHE_ECDSA_WITH_AES_256_CBC_SHA384: return "ECDHE_ECDSA_WITH_AES_256_CBC_SHA384"
        case .ECDHE_RSA_WITH_AES_128_CBC_SHA256: return "ECDHE_RSA_WITH_AES_128_CBC_SHA256"
        case .ECDHE_RSA_WITH_AES_256_CBC_SHA384: return "ECDHE_RSA_WITH_AES_256_CBC_SHA384"
        case .ECDHE_ECDSA_WITH_AES_128_GCM_SHA256: return "ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        case .ECDHE_ECDSA_WITH_AES_256_GCM_SHA384: return "ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        case .ECDHE_RSA_WITH_AES_128_GCM_SHA256: return "ECDHE_RSA_WITH_AES_128_GCM_SHA256"
        case .ECDHE_RSA_WITH_AES_256_GCM_SHA384: return "ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        case .ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256: return "ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
        case .ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256: return "ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
        case .AES_128_GCM_SHA256: return "AES_128_GCM_SHA256"
        case .AES_256_GCM_SHA384: return "AES_256_GCM_SHA384"
        case .CHACHA20_POLY1305_SHA256: return "CHACHA20_POLY1305_SHA256"
        @unknown default: return L10n.tr("pulse.status.unknown")
        }
    }
}

extension tls_protocol_version_t {
    package var description: String {
        switch self {
        case .TLSv10: return "TLS 1.0"
        case .TLSv11: return "TLS 1.1"
        case .TLSv12: return "TLS 1.2"
        case .TLSv13: return "TLS 1.3"
        case .DTLSv10: return "DTLS 1.0"
        case .DTLSv12: return "DTLS 1.2"
        @unknown default: return L10n.tr("pulse.status.unknown")
        }
    }
}

package func descriptionForURLErrorCode(_ code: Int) -> String {
    switch code {
    case NSURLErrorUnknown: return L10n.tr("pulse.error.unknown")
    case NSURLErrorCancelled: return L10n.tr("pulse.error.cancelled")
    case NSURLErrorBadURL: return L10n.tr("pulse.error.bad_url")
    case NSURLErrorTimedOut: return L10n.tr("pulse.error.timed_out")
    case NSURLErrorUnsupportedURL: return L10n.tr("pulse.error.unsupported_url")
    case NSURLErrorCannotFindHost: return L10n.tr("pulse.error.cannot_find_host")
    case NSURLErrorCannotConnectToHost: return L10n.tr("pulse.error.cannot_connect_to_host")
    case NSURLErrorNetworkConnectionLost: return L10n.tr("pulse.error.network_connection_lost")
    case NSURLErrorDNSLookupFailed: return L10n.tr("pulse.error.dns_lookup_failed")
    case NSURLErrorHTTPTooManyRedirects: return L10n.tr("pulse.error.http_too_many_redirects")
    case NSURLErrorResourceUnavailable: return L10n.tr("pulse.error.resource_unavailable")
    case NSURLErrorNotConnectedToInternet: return L10n.tr("pulse.error.not_connected_to_internet")
    case NSURLErrorRedirectToNonExistentLocation: return L10n.tr("pulse.error.redirect_to_non_existent_location")
    case NSURLErrorBadServerResponse: return L10n.tr("pulse.error.bad_server_response")
    case NSURLErrorUserCancelledAuthentication: return L10n.tr("pulse.error.user_cancelled_authentication")
    case NSURLErrorUserAuthenticationRequired: return L10n.tr("pulse.error.user_authentication_required")
    case NSURLErrorZeroByteResource: return L10n.tr("pulse.error.zero_byte_resource")
    case NSURLErrorCannotDecodeRawData: return L10n.tr("pulse.error.cannot_decode_raw_data")
    case NSURLErrorCannotDecodeContentData: return L10n.tr("pulse.error.cannot_decode_content_data")
    case NSURLErrorCannotParseResponse: return L10n.tr("pulse.error.cannot_parse_response")
    case NSURLErrorAppTransportSecurityRequiresSecureConnection: return L10n.tr("pulse.error.ats_requirement_failed")
    case NSURLErrorFileDoesNotExist: return L10n.tr("pulse.error.file_does_not_exist")
    case NSURLErrorFileIsDirectory: return L10n.tr("pulse.error.file_is_directory")
    case NSURLErrorNoPermissionsToReadFile: return L10n.tr("pulse.error.no_permissions_to_read_file")
    case NSURLErrorDataLengthExceedsMaximum: return L10n.tr("pulse.error.data_length_exceeds_maximum")
    case NSURLErrorFileOutsideSafeArea: return L10n.tr("pulse.error.file_outside_safe_area")
    case NSURLErrorSecureConnectionFailed: return L10n.tr("pulse.error.secure_connection_failed")
    case NSURLErrorServerCertificateHasBadDate: return L10n.tr("pulse.error.server_certificate_bad_date")
    case NSURLErrorServerCertificateUntrusted: return L10n.tr("pulse.error.server_certificate_untrusted")
    case NSURLErrorServerCertificateHasUnknownRoot: return L10n.tr("pulse.error.server_certificate_unknown_root")
    case NSURLErrorServerCertificateNotYetValid: return L10n.tr("pulse.error.server_certificate_not_valid")
    case NSURLErrorClientCertificateRejected: return L10n.tr("pulse.error.client_certificate_rejected")
    case NSURLErrorClientCertificateRequired: return L10n.tr("pulse.error.client_certificate_required")
    case NSURLErrorCannotLoadFromNetwork: return L10n.tr("pulse.error.cannot_load_from_network")
    case NSURLErrorCannotCreateFile: return L10n.tr("pulse.error.cannot_create_file")
    case NSURLErrorCannotOpenFile: return L10n.tr("pulse.error.cannot_open_file")
    case NSURLErrorCannotCloseFile: return L10n.tr("pulse.error.cannot_close_file")
    case NSURLErrorCannotWriteToFile: return L10n.tr("pulse.error.cannot_write_to_file")
    case NSURLErrorCannotRemoveFile: return L10n.tr("pulse.error.cannot_remove_file")
    case NSURLErrorCannotMoveFile: return L10n.tr("pulse.error.cannot_move_file")
    case NSURLErrorDownloadDecodingFailedMidStream: return L10n.tr("pulse.error.download_decoding_failed")
    case NSURLErrorDownloadDecodingFailedToComplete: return L10n.tr("pulse.error.download_decoding_failed")
    case NSURLErrorInternationalRoamingOff: return L10n.tr("pulse.error.roaming_off")
    case NSURLErrorCallIsActive: return L10n.tr("pulse.error.call_is_active")
    case NSURLErrorDataNotAllowed: return L10n.tr("pulse.error.data_not_allowed")
    case NSURLErrorRequestBodyStreamExhausted: return L10n.tr("pulse.error.request_stream_exhausted")
    case NSURLErrorBackgroundSessionRequiresSharedContainer: return L10n.tr("pulse.error.background_session_requires_shared_container")
    case NSURLErrorBackgroundSessionInUseByAnotherProcess: return L10n.tr("pulse.error.background_session_in_use")
    case NSURLErrorBackgroundSessionWasDisconnected: return L10n.tr("pulse.error.background_session_disconnected")
    default: return "–"
    }
}

extension URLRequest.CachePolicy {
    package var localizedDescription: String {
        switch self {
        case .useProtocolCachePolicy: return L10n.tr("pulse.cache.use_protocol_cache_policy")
        case .reloadIgnoringLocalCacheData: return L10n.tr("pulse.cache.reload_ignoring_local_cache_data")
        case .reloadIgnoringLocalAndRemoteCacheData: return L10n.tr("pulse.cache.reload_ignoring_local_and_remote_cache_data")
        case .returnCacheDataElseLoad: return L10n.tr("pulse.cache.return_cache_data_else_load")
        case .returnCacheDataDontLoad: return L10n.tr("pulse.cache.return_cache_data_dont_load")
        case .reloadRevalidatingCacheData: return L10n.tr("pulse.cache.reload_revalidating_cache_data")
        @unknown default: return L10n.tr("pulse.status.unknown")
        }
    }
}
