//
//  SearchResultVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import FirebaseFirestore

struct SearchResultStore: Identifiable, Hashable {
    let id: String
    let name: String
    let imgURL: URL?
}

struct SearchResultFeed: Identifiable, Hashable {
    let id: String
    let name: String        // = title
    let mediaURL: URL?
    let likeCount: Int
    let promoKind: String   // "product" | "event" | ...
    let storeId: String
}

@MainActor
final class SearchResultVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stores: [SearchResultStore] = []
    @Published var products: [SearchResultFeed] = []
    @Published var events: [SearchResultFeed] = []

    private let db = Firestore.firestore()

    // 좋아요 수 집계 (Aggregation Count → 실패 시 문서수 폴백)
    private func likeCount(for feedId: String) async -> Int {
        do {
            let q = db.collection("feedLikes").whereField("feedId", isEqualTo: feedId)
            if let agg = try? await q.count.getAggregation(source: .server) {
                return Int(truncating: agg.count)
            } else {
                let docs = try await q.getDocuments()
                return docs.documents.count
            }
        } catch {
            // 에러 시 0으로 폴백
            return 0
        }
    }

    func fetch(keyword: String) async {
        let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if kw.isEmpty {
            self.stores = []; self.products = []; self.events = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // 1) 점포/피드 최신 일부만 가져오기
            async let storeSnapTask = db.collection("stores")
                .order(by: "updatedAt", descending: true)
                .limit(to: 120)
                .getDocuments()

            async let feedSnapTask = db.collection("feeds")
                .order(by: "updatedAt", descending: true)
                .limit(to: 200)
                .getDocuments()

            let (storeSnap, feedSnap) = try await (storeSnapTask, feedSnapTask)
            let lower = kw.lowercased()

            // --- Stores (로컬 contains 필터) ---
            let foundStores: [SearchResultStore] = storeSnap.documents.compactMap { d in
                let data = d.data()
                let id   = (data["id"] as? String) ?? d.documentID
                let name = (data["storeName"] as? String) ?? ""
                guard name.lowercased().contains(lower) else { return nil }
                let url  = (data["profileImageURL"] as? String).flatMap(URL.init(string:))
                return SearchResultStore(id: id, name: name, imgURL: url)
            }

            // --- Feeds 기본형(좋아요 수 제외) ---
            struct Basic: Hashable {
                let id: String
                let title: String
                let mediaURL: URL?
                let promoKind: String
                let storeId: String
            }

            let basicsAll: [Basic] = feedSnap.documents.compactMap { d in
                let data = d.data()
                let id    = (data["id"] as? String) ?? d.documentID
                let title = (data["title"] as? String) ?? ""
                let isPublished = (data["isPublished"] as? Bool) ?? false
                guard isPublished, title.lowercased().contains(lower) else { return nil }
                let mediaURL = (data["mediaUrl"] as? String).flatMap(URL.init(string:))
                let promo    = (data["promoKind"] as? String) ?? ""
                let storeId  = (data["storeId"] as? String) ?? ""
                return Basic(id: id, title: title, mediaURL: mediaURL, promoKind: promo, storeId: storeId)
            }

            let prodBasics = basicsAll.filter { $0.promoKind == "product" }
            let eventBasics = basicsAll.filter { $0.promoKind == "event" }

            // --- 좋아요 수 동시 집계 후 SearchResultFeed 생성 ---
            func enrich(_ basics: [Basic]) async -> [SearchResultFeed] {
                var result: [SearchResultFeed] = []
                result.reserveCapacity(basics.count)

                await withTaskGroup(of: SearchResultFeed?.self) { group in
                    for b in basics {
                        group.addTask { [weak self] in
                            guard let self else { return nil }
                            let count = await self.likeCount(for: b.id)
                            return SearchResultFeed(
                                id: b.id,
                                name: b.title,
                                mediaURL: b.mediaURL,
                                likeCount: count,
                                promoKind: b.promoKind,
                                storeId: b.storeId
                            )
                        }
                    }
                    for await item in group {
                        if let item { result.append(item) }
                    }
                }
                return result
            }

            // 3) 결과 반영
            self.stores   = foundStores
            self.products = await enrich(prodBasics)
            self.events   = await enrich(eventBasics)
            self.isLoading = false

        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
