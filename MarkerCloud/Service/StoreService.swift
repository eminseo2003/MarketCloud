//
//  StoreService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

private struct StoreDoc: Decodable {
    let storeName: String?
    let profileImageURL: String?
    let marketId: String?
    let categoryId: Int?
    let phoneNumber: String?
    let weekdayStart: Date?
    let weekdayEnd: Date?
    let weekendStart: Date?
    let weekendEnd: Date?
    let address: String?
    let paymentMethods: Set<PaymentMethod>
    let storeDescript: String?
    let feeds: [Feed]
}

enum StoreService {
    static let db = Firestore.firestore()
    
    private static func isValidId(_ id: String?) -> Bool {
            guard let raw = id?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !raw.isEmpty, !raw.contains("/") else { return false }
            return true
        }
    
    // storeId로 점포명만 가져오기
    static func fetchStoreName(storeId: String) async -> String? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["storeName"] as? String
        } catch {
            print("[StoreService] fetchStoreName error:", error)
            return nil
        }
    }
    
    // storeId로 프로필 이미지 URL 가져오기
    // 1) 문서의 profileImageURL 사용
    // 2) 없으면 Storage 경로 stores/{storeId}/profile.jpg 시도 (폴백)
    static func fetchStoreProfileURL(storeId: String) async -> URL? {
        guard isValidId(storeId) else {
                    print("[StoreService][fetchStoreProfileURL] ❌ empty storeId=\(storeId)")
                    return nil
                }
                do {
                    let ref = db.collection("stores").document(storeId)
                    print("[StoreService][fetchStoreProfileURL] path=\(ref.path)")
                    let snap = try await ref.getDocument()
                    guard let dict = snap.data() else {
                        print("[StoreService][fetchStoreProfileURL] no doc")
                        return nil
                    }
                    if let urlStr = dict["profileImageURL"] as? String,
                       !urlStr.isEmpty, let url = URL(string: urlStr) {
                        print("[StoreService][fetchStoreProfileURL] from field")
                        return url
                    }
                    // (옵션) 필드 없으면 Storage 폴백
                    let storageRef = Storage.storage().reference()
                        .child("stores/\(storeId)/profile.jpg")
                    do {
                        let url = try await storageRef.downloadURL()
                        print("[StoreService][fetchStoreProfileURL] from storage")
                        return url
                    } catch {
                        print("[StoreService][fetchStoreProfileURL] storage fallback failed:", error)
                        return nil
                    }
                } catch {
                    print("[StoreService][fetchStoreProfileURL] error:", error)
                    return nil
                }
    }
    
    static func fetchStoreBasics(storeId: String) async -> (name: String?, profileURL: URL?) {
        async let name = fetchStoreName(storeId: storeId)
        async let url  = fetchStoreProfileURL(storeId: storeId)
        return await (name, url)
    }
    
    // storeId로 마켓아이디만 가져오기
    static func fetchMarketId(storeId: String) async -> String? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["marketId"] as? String
        } catch {
            print("[StoreService] fetchMarketId error:", error)
            return nil
        }
    }
    // storeId로 categoryId만 가져오기
    static func fetchCategoryId(storeId: String) async -> Int? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["categoryId"] as? Int
        } catch {
            print("[StoreService] fetchCategoryId error:", error)
            return nil
        }
    }
    // storeId로 phoneNumber만 가져오기
    static func fetchPhoneNumber(storeId: String) async -> String? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["phoneNumber"] as? String
        } catch {
            print("[StoreService] fetchphoneNumber error:", error)
            return nil
        }
    }
    // storeId로 weekdayStart만 가져오기
    static func fetchWeekdayStart(storeId: String) async -> Date? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            return (snap.get("weekdayStart") as? Timestamp)?.dateValue()
                ?? (snap.get("weekdayStart") as? Date) // 혹시 Date로 저장된 경우 대비
        } catch {
            print("[StoreService] fetchWeekdayStart error:", error)
            return nil
        }
    }

    // storeId로 weekdayEnd만 가져오기
    static func fetchWeekdayEnd(storeId: String) async -> Date? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            return (snap.get("weekdayEnd") as? Timestamp)?.dateValue()
                ?? (snap.get("weekdayEnd") as? Date)
        } catch {
            print("[StoreService] fetchWeekdayEnd error:", error)
            return nil
        }
    }

    // storeId로 weekendStart만 가져오기
    static func fetchWeekendStart(storeId: String) async -> Date? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            return (snap.get("weekendStart") as? Timestamp)?.dateValue()
                ?? (snap.get("weekendStart") as? Date)
        } catch {
            print("[StoreService] fetchWeekendStart error:", error)
            return nil
        }
    }

    // storeId로 weekendEnd만 가져오기
    static func fetchWeekendEnd(storeId: String) async -> Date? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            return (snap.get("weekendEnd") as? Timestamp)?.dateValue()
                ?? (snap.get("weekendEnd") as? Date)
        } catch {
            print("[StoreService] fetchWeekendEnd error:", error)
            return nil
        }
    }
    // storeId로 storeDescript만 가져오기
    static func fetchstoreDescript(storeId: String) async -> String? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["storeDescript"] as? String
        } catch {
            print("[StoreService] fetchstoreDescript error:", error)
            return nil
        }
    }
    // storeId로 address만 가져오기
    static func fetchaddress(storeId: String) async -> String? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["address"] as? String
        } catch {
            print("[StoreService] fetchaddress error:", error)
            return nil
        }
    }
    // storeId로 paymentMethods만 가져오기
    static func fetchPaymentMethods(storeId: String) async -> Set<PaymentMethod> {
            do {
                let snap = try await db.collection("stores").document(storeId).getDocument()
                guard
                    let data = snap.data(),
                    let strs = data["paymentMethods"] as? [String]
                else {
                    return []
                }

                let mapped = strs.compactMap { mapPaymentString($0) }
                return Set(mapped)
            } catch {
                print("[StoreService] fetchPaymentMethods error:", error.localizedDescription)
                return []
            }
        }
    private static func mapPaymentString(_ raw: String) -> PaymentMethod? {
            let s = raw.replacingOccurrences(of: " ", with: "").lowercased()
            switch s {
            case "온누리상품권", "onnuri", "onnurivoucher", "onnuri상품권":
                return .onnuriVoucher
            case "제로페이", "zeropay":
                return .zeropay
            case "민생회복소비쿠폰", "민생회복쿠폰", "livelihoodcoupon":
                return .livelihoodCoupon
            default:
                return nil
            }
        }
    // storeId로 feeds만 가져오기
    static func fetchFeeds(storeId: String, limit: Int = 50) async -> [Feed] {
            do {
                var query: Query = db.collection("feeds")
                    .whereField("storeId", isEqualTo: storeId)

                if let _ = try? await db.collection("feeds").limit(to: 1)
                    .order(by: "updatedAt", descending: true).getDocuments() {
                    query = query.order(by: "updatedAt", descending: true)
                } else {
                    query = query.order(by: "createdAt", descending: true)
                }

                query = query.limit(to: limit)

                let snap = try await query.getDocuments()
                let feeds: [Feed] = snap.documents.compactMap { doc in
                    mapFeed(dict: doc.data())
                }
                print("[StoreService] fetchFeed = ", feeds.count)
                return feeds
            } catch {
                print("[StoreService] fetchFeeds error:", error.localizedDescription)
                return []
            }
        }
    private static func mapFeed(dict: [String: Any]) -> Feed? {
        guard
            let idStr     = dict["id"] as? String,
            let storeIdStr = dict["storeId"] as? String,
            let title     = dict["title"] as? String,
            let body      = dict["body"] as? String,
            let mediaUrlS = dict["mediaUrl"] as? String,
            let mediaUrl  = URL(string: mediaUrlS)
        else {
            return nil
        }

        guard
            let feedUUID  = UUID(uuidString: idStr),
            let storeUUID = UUID(uuidString: storeIdStr)
        else {
            return nil
        }

        let isPublished = (dict["isPublished"] as? Bool) ?? false
        let promoRaw = (dict["promoKind"] as? String)?.lowercased() ?? "store"
        let mediaRaw = (dict["mediaType"] as? String)?.lowercased() ?? "image"
        let promoKind = PromoKind(rawValue: promoRaw) ?? .store
        let mediaType = MediaType(rawValue: mediaRaw) ?? .image

        let createdAt: Date = (dict["updatedAt"] as? Timestamp)?.dateValue()
            ?? (dict["createdAt"] as? Timestamp)?.dateValue()
            ?? Date()

        let prompt = dict["prompt"] as? String ?? ""

        var storeInfo: StoreFeedPayload?
        if let si = dict["storeInfo"] as? [String: Any] {
            let desc = si["description"] as? String
            let imgU = (si["imgUrl"] as? String)
            storeInfo = StoreFeedPayload(description: desc, imgUrl: imgU)
        }

        return Feed(
            id: feedUUID,
            storeId: storeUUID,
            isPublished: isPublished,
            promoKind: promoKind,
            mediaType: mediaType,
            title: title,
            prompt: prompt,
            mediaUrl: mediaUrl,
            body: body,
            createdAt: createdAt,
            event: nil,
            storeInfo: storeInfo,
            product: nil,
            reviews: []
        )
    }
    
    static func fetchStore(storeId: String) async -> (storeName: String?, profileImageURL: URL?, marketId: String?, categoryId: Int?, phoneNumber: String?, weekdayStart: Date?, weekdayEnd: Date?, weekendStart: Date?, weekendEnd: Date?, address: String?, storeDescript: String?, paymentMethods: Set<PaymentMethod>, feeds: [Feed]) {
        async let storeName = fetchStoreName(storeId: storeId)
        async let profileImageURL  = fetchStoreProfileURL(storeId: storeId)
        async let marketId  = fetchMarketId(storeId: storeId)
        async let categoryId  = fetchCategoryId(storeId: storeId)
        async let phoneNumber  = fetchPhoneNumber(storeId: storeId)
        async let weekdayStart  = fetchWeekdayStart(storeId: storeId)
        async let weekdayEnd  = fetchWeekdayEnd(storeId: storeId)
        async let weekendStart  = fetchWeekendStart(storeId: storeId)
        async let weekendEnd  = fetchWeekendEnd(storeId: storeId)
        async let address  = fetchaddress(storeId: storeId)
        async let storeDescript  = fetchstoreDescript(storeId: storeId)
        async let paymentMethods  = fetchPaymentMethods(storeId: storeId)
        async let feeds  = fetchFeeds(storeId: storeId)
        return await (storeName, profileImageURL, marketId, categoryId, phoneNumber, weekdayStart, weekdayEnd, weekendStart, weekendEnd, address, storeDescript, paymentMethods, feeds)
    }
}
