import Foundation
import SwiftSignalKit
import WGCore

/// The real public exteraGram badge feed, exactly the endpoint the Android client uses
/// (`ApiService.getAllProfiles`): `GET https://api.exteragram.app/api/v1/profiles`.
///
/// The whole catalog is fetched (an anonymous list); no Telegram user id is put into the URL.
/// ETag is reused through `WGNetworkRequest.etag`, so a 304 costs almost nothing. No extra headers,
/// no token, no fake badge: if the server does not list a user, the app shows nothing.
enum WGExteraBadgeAPI {
    static let baseURL = "https://api.exteragram.app/api/v1/"
    static let requestTimeout: Double = 15.0
    static let maxResponseBytes = 2 * 1024 * 1024

    enum WGExteraBadgeResult {
        case updated(WGExteraBadgeSnapshot)
        case notModified
        case failed
    }

    static var profilesURL: URL? {
        return URL(string: baseURL + "profiles")
    }

    static func fetch(etag: String?) -> Signal<WGExteraBadgeResult, NoError> {
        guard let url = WGExteraBadgeAPI.profilesURL else {
            return .single(.failed)
        }
        let request = WGNetworkRequest(url: url, etag: etag, maxBytes: WGExteraBadgeAPI.maxResponseBytes)
        return WGNetwork.shared.fetch(request)
        |> map { response -> WGExteraBadgeResult in
            if response.notModified {
                return .notModified
            }
            guard let data = response.data else {
                return .failed
            }
            do {
                let decoder = JSONDecoder()
                let profiles = try decoder.decode([WGExteraBadgeProfile].self, from: data)
                let snapshot = WGExteraBadgeSnapshot(profiles: profiles, etag: response.etag ?? etag, fetchedAt: WGExteraBadgeStore.now())
                return .updated(snapshot)
            } catch {
                return .failed
            }
        }
        |> `catch` { _ -> Signal<WGExteraBadgeResult, NoError> in
            return .single(.failed)
        }
        |> timeout(WGExteraBadgeAPI.requestTimeout, queue: Queue.concurrentDefaultQueue(), alternate: .single(.failed))
    }
}
