//
//  FeedService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

private struct FeedDoc: Decodable {
    let storeId: String?
    let isPublished: Bool?
    let marketId: String?
    let promoKind: String?
    let mediaType: String?
    let title: String?
    let prompt: String?
    let mediaUrl: String?
    let body: String?
    let createdAt: Date?
    let event: EventFeedPayload?
    let storeInfo: StoreFeedPayload?
    let product: ProductFeedPayload?
}

enum FeedService {
    static let db = Firestore.firestore()
    
    // feedId로 storeId만 가져오기
    static func fetchstoreId(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["storeId"] as? String
        } catch {
            print("[FeedService] fetchstoreId error:", error)
            return nil
        }
    }
    // feedId로 isPublished만 가져오기
    static func fetchisPublished(feedId: String) async -> Bool? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["isPublished"] as? Bool
        } catch {
            print("[FeedService] fetchisPublished error:", error)
            return nil
        }
    }
    // feedId로 marketId만 가져오기
    static func fetchmarketId(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["marketId"] as? String
        } catch {
            print("[FeedService] fetchmarketId error:", error)
            return nil
        }
    }
    // feedId로 promoKind만 가져오기
    static func fetchpromoKind(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["promoKind"] as? String
        } catch {
            print("[FeedService] fetchpromoKind error:", error)
            return nil
        }
    }
    // feedId로 mediaType만 가져오기
    static func fetchmediaType(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["mediaType"] as? String
        } catch {
            print("[FeedService] fetchmediaType error:", error)
            return nil
        }
    }
    // feedId로 title만 가져오기
    static func fetchtitle(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["title"] as? String
        } catch {
            print("[FeedService] fetchtitle error:", error)
            return nil
        }
    }
    // feedId로 prompt만 가져오기
    static func fetchprompt(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["prompt"] as? String
        } catch {
            print("[FeedService] fetchprompt error:", error)
            return nil
        }
    }
    // feedId로 mediaUrl만 가져오기
    static func fetchmediaUrl(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["mediaUrl"] as? String
        } catch {
            print("[FeedService] fetchmediaUrl error:", error)
            return nil
        }
    }
    // feedId로 body만 가져오기
    static func fetchbody(feedId: String) async -> String? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["body"] as? String
        } catch {
            print("[FeedService] fetchbody error:", error)
            return nil
        }
    }
    // feedId로 createdAt만 가져오기
    static func fetchcreatedAt(feedId: String) async -> Date? {
        do {
            let snap = try await db.collection("feeds").document(feedId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["createdAt"] as? Date
        } catch {
            print("[FeedService] fetchcreatedAt error:", error)
            return nil
        }
    }
    // feedId로 event만 가져오기
    static func fetchEventPayload(feedId: String) async -> EventFeedPayload? {
        do {
            let doc = try await db.collection("feeds").document(feedId).getDocument()
            return parseEvent(from: doc.data()?["event"])
        } catch {
            print("[FeedService] fetchEventPayload error:", error)
            return nil
        }
    }
    // feedId로 storeInfo만 가져오기
    static func fetchStoreInfoPayload(feedId: String) async -> StoreFeedPayload? {
        do {
            let doc = try await db.collection("feeds").document(feedId).getDocument()
            return parseStoreInfo(from: doc.data()?["storeInfo"])
        } catch {
            print("[FeedService] fetchStoreInfoPayload error:", error)
            return nil
        }
    }
    // feedId로 product만 가져오기
    static func fetchProductPayload(feedId: String) async -> ProductFeedPayload? {
        do {
            let doc = try await db.collection("feeds").document(feedId).getDocument()
            return parseProduct(from: doc.data()?["product"])
        } catch {
            print("[FeedService] fetchProductPayload error:", error)
            return nil
        }
    }
    private static func parseEvent(from any: Any?) -> EventFeedPayload? {
        guard let dict = any as? [String: Any] else { return nil }

        // eventName을 필수로 본다면 guard로 체크
        let name = (dict["eventName"] as? String) ?? ""

        let desc = dict["description"] as? String

        let img = dict["imgUrl"] as? String

        let start: Date? = dateFromFirestoreValue(dict["startAt"])
        let end:   Date? = dateFromFirestoreValue(dict["endAt"])

        return EventFeedPayload(
            eventName: name,
            description: desc,
            imgUrl: img,
            startAt: start,
            endAt: end
        )
    }

    private static func dateFromFirestoreValue(_ value: Any?) -> Date? {
        switch value {
        case let ts as Timestamp:
            return ts.dateValue()
        case let d as Date:
            return d
        case let s as String:
            let iso = ISO8601DateFormatter()
            if let d = iso.date(from: s) { return d }
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
                           "yyyy-MM-dd'T'HH:mm:ssXXXXX",
                           "yyyy-MM-dd"] {
                f.dateFormat = format
                if let d = f.date(from: s) { return d }
            }
            return nil
        default:
            return nil
        }
    }
    
    private static func parseStoreInfo(from any: Any?) -> StoreFeedPayload? {
        guard let dict = any as? [String: Any] else { return nil }
        return StoreFeedPayload(
            description: dict["description"] as? String,
            imgUrl: dict["imgUrl"] as? String
        )
    }
    
    private static func parseProduct(from any: Any?) -> ProductFeedPayload? {
        guard let dict = any as? [String: Any] else { return nil }
        // productName / imgUrl 는 스키마상 필수라 가정
        guard let name = dict["productName"] as? String,
              let img  = dict["imgUrl"] as? String else { return nil }
        let payload = ProductFeedPayload(
            productName: name,
            description: dict["description"] as? String,
            imgUrl: img,
            productCategoryId: dict["productCategoryId"] as? Int
        )
        return payload
    }
    static func fetchFeed(feedId: String) async -> (storeId: String?, isPublished: Bool?, marketId: String?, promoKind: String?, mediaType: String?, title: String?, prompt: String?, mediaUrl: String?, body: String?, createdAt: Date?, event: EventFeedPayload?, storeInfo: StoreFeedPayload?, product: ProductFeedPayload?) {
        async let storeId = fetchstoreId(feedId: feedId)
        async let isPublished  = fetchisPublished(feedId: feedId)
        async let marketId  = fetchmarketId(feedId: feedId)
        async let promoKind  = fetchpromoKind(feedId: feedId)
        async let mediaType  = fetchmediaType(feedId: feedId)
        async let title  = fetchtitle(feedId: feedId)
        async let prompt  = fetchprompt(feedId: feedId)
        async let mediaUrl  = fetchmediaUrl(feedId: feedId)
        async let body  = fetchbody(feedId: feedId)
        async let createdAt  = fetchcreatedAt(feedId: feedId)
        async let event  = fetchEventPayload(feedId: feedId)
        async let storeInfo  = fetchStoreInfoPayload(feedId: feedId)
        async let product  = fetchProductPayload(feedId: feedId)
        return await (storeId, isPublished, marketId, promoKind, mediaType, title, prompt, mediaUrl, body, createdAt, event, storeInfo, product)
    }
}
