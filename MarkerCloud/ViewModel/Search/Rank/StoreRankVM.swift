//
//  StoreRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import FirebaseFirestore

struct RankedStore: Identifiable, Hashable {
    let id: String
    let name: String
    let profileURL: URL?
    let followerCount: Int
    let updatedAt: Date?
}

@MainActor
final class StoreRankVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stores: [RankedStore] = []

    private let db = Firestore.firestore()

    // 시장(marketId) 내 모든 점포를 구독자 수 내림차순으로 정렬해서 상위 N개를 반환
    func loadTopStores(marketId: Int, limit: Int = 20) async {
        isLoading = true
        errorMessage = nil
        stores = []

        do {
            // 1) 시장 내 점포들 후보
            let snap = try await db.collection("stores")
                .whereField("marketId", isEqualTo: marketId)
                .getDocuments()

            struct Base {
                let id: String
                let name: String
                let profileURL: URL?
                let updatedAt: Date?
            }

            let bases: [Base] = snap.documents.map { d in
                let data = d.data()
                let id   = (data["id"] as? String) ?? d.documentID
                let name = (data["storeName"] as? String) ?? "이름 없음"
                let url  = (data["profileImageURL"] as? String).flatMap(URL.init(string:))
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                return Base(id: id, name: name, profileURL: url, updatedAt: updatedAt)
            }

            // 2) 각 점포의 구독 수 집계 (Aggregation Count → 실패 시 문서 수 폴백)
            var ranked: [RankedStore] = []
            ranked.reserveCapacity(bases.count)

            try await withThrowingTaskGroup(of: RankedStore.self) { group in
                for b in bases {
                    group.addTask { [db] in
                        let q = db.collection("subscription").whereField("storeId", isEqualTo: b.id)

                        let count: Int
                        if let agg = try? await q.count.getAggregation(source: .server) {
                            count = Int(truncating: agg.count)
                        } else {
                            let docs = try await q.getDocuments()
                            count = docs.documents.count
                        }

                        return RankedStore(
                            id: b.id,
                            name: b.name,
                            profileURL: b.profileURL,
                            followerCount: count,     // 0이어도 포함
                            updatedAt: b.updatedAt
                        )
                    }
                }

                for try await item in group {
                    ranked.append(item)
                }
            }

            // 3) 구독 수 내림차순, 동률이면 updatedAt 최신순
            ranked.sort {
                if $0.followerCount != $1.followerCount { return $0.followerCount > $1.followerCount }
                let l = $0.updatedAt ?? .distantPast
                let r = $1.updatedAt ?? .distantPast
                return l > r
            }

            // 4) 상위 N개만
            self.stores = Array(ranked.prefix(limit))
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
