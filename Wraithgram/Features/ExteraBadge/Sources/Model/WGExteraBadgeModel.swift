import Foundation

/// DTO of `GET https://api.exteragram.app/api/v1/profiles`.
///
/// Mirrors exteraGram's `ApiProfile` / `Badge` (`BadgesController`):
/// `id`, `type`, `status` (`DEFAULT | DEVELOPER | SUPPORTER`), `badge {documentId, text}`,
/// `number`, `deleted`, `canChangeBadge`. Unknown fields are ignored so a server addition does
/// not break the app.
struct WGExteraBadgeDocument: Codable, Equatable, WGSettingValue {
    let documentId: Int64?
    let text: String?

    private enum CodingKeys: String, CodingKey {
        case documentId
        case text
    }

    init(documentId: Int64?, text: String?) {
        self.documentId = documentId
        self.text = text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try container.decodeIfPresent(Int64.self, forKey: .documentId)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
    }
}

/// `id` is sent as a number by the Android client; accept a decimal string as well.
private struct WGExteraFlexibleInt64: Decodable {
    let value: Int64

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Int64.self) {
            self.value = number
        } else if let string = try? container.decode(String.self), let number = Int64(string) {
            self.value = number
        } else {
            throw DecodingError.typeMismatch(Int64.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected an integer or decimal string"))
        }
    }
}

struct WGExteraBadgeProfile: Codable, Equatable, WGSettingValue {
    let id: Int64
    let type: String?
    let status: String?
    let badge: WGExteraBadgeDocument?
    let number: Int?
    let deleted: Bool
    let canChangeBadge: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case status
        case badge
        case number
        case deleted
        case canChangeBadge
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // The Android client uses a Long id; accept a decimal string too, so a server-side
        // serialization change cannot silently hide every badge.
        guard let id = try container.decodeIfPresent(WGExteraFlexibleInt64.self, forKey: .id) else {
            throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing profile id"))
        }
        self.id = id.value
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.badge = try container.decodeIfPresent(WGExteraBadgeDocument.self, forKey: .badge)
        self.number = try container.decodeIfPresent(Int.self, forKey: .number)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted) ?? false
        self.canChangeBadge = try container.decodeIfPresent(Bool.self, forKey: .canChangeBadge) ?? false
    }

    var isSupporter: Bool {
        return self.status == "SUPPORTER"
    }

    var isDeveloper: Bool {
        return self.status == "DEVELOPER"
    }

    /// The text to draw in the pill. Never invent a title: prefer the server text, then the status.
    var displayText: String? {
        if let text = self.badge?.text, !text.isEmpty {
            return text
        }
        switch self.status {
        case "SUPPORTER":
            return "SUPPORTER"
        case "DEVELOPER":
            return "DEVELOPER"
        default:
            return nil
        }
    }
}

/// The cached answer of the whole public catalog (no user id leaves the device in a request).
struct WGExteraBadgeSnapshot: Codable, Equatable, WGSettingValue {
    let profiles: [WGExteraBadgeProfile]
    let etag: String?
    let fetchedAt: Int32

    init(profiles: [WGExteraBadgeProfile], etag: String?, fetchedAt: Int32) {
        self.profiles = profiles
        self.etag = etag
        self.fetchedAt = fetchedAt
    }

    func profile(for userId: Int64) -> WGExteraBadgeProfile? {
        return self.profiles.first(where: { $0.id == userId && !$0.deleted })
    }
}
