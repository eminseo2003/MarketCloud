//
//  EventRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import FirebaseFirestore

struct RankedEvent: Identifiable, Hashable {
    let id: String              // feedId
    let title: String
    let mediaURL: URL?
    let storeId: String
    let likeCount: Int
    let createdAt: Date?
}

@MainActor
final class EventRankVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var events: [RankedEvent] = []

    private let db = Firestore.firestore()

    func loadTopEvents(
        marketId: Int? = nil,
        storeId: String? = nil,
        candidateLimit: Int = 100,
        topN: Int = 20,
        includeZero: Bool = true
    ) async {
        isLoading = true
        errorMessage = nil
        events = []

        do {
            // 1) event + 공개된 피드 후보 가져오기
            var q: Query = db.collection("feeds")
                .whereField("promoKind", isEqualTo: "event")
                .whereField("isPublished", isEqualTo: true)

            if let marketId { q = q.whereField("marketId", isEqualTo: marketId) }
            if let storeId  { q = q.whereField("storeId",  isEqualTo: storeId) }

            // 후보는 최근 업데이트 순으로 제한
            q = q.order(by: "updatedAt", descending: true).limit(to: candidateLimit)

            let snap = try await q.getDocuments()

            struct Base: Hashable {
                let id: String
                let title: String
                let mediaURL: URL?
                let storeId: String
                let createdAt: Date?
                let updatedAt: Date?
            }

            let bases: [Base] = snap.documents.map { d in
                let data = d.data()
                let id  = (data["id"] as? String) ?? d.documentID
                let title = (data["title"] as? String) ?? ""
                let mediaURL = (data["mediaUrl"] as? String).flatMap(URL.init(string:))
                let storeId = (data["storeId"] as? String) ?? ""
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                return Base(id: id, title: title, mediaURL: mediaURL, storeId: storeId, createdAt: createdAt, updatedAt: updatedAt)
            }

            // 2) 각 후보의 좋아요 수 집계 (Aggregation Count 사용, 실패 시 문서 수 폴백)
            func likeCount(for feedId: String) async throws -> Int {
                let lq = db.collection("feedLikes").whereField("feedId", isEqualTo: feedId)
                if let agg = try? await lq.count.getAggregation(source: .server) {
                    return Int(truncating: agg.count)
                } else {
                    let docs = try await lq.getDocuments()
                    return docs.documents.count
                }
            }

            var ranked: [RankedEvent] = []
            ranked.reserveCapacity(bases.count)

            try await withThrowingTaskGroup(of: RankedEvent?.self) { group in
                for b in bases {
                    group.addTask {
                        let c = try await likeCount(for: b.id)
                        if c == 0 && !includeZero { return nil }
                        return RankedEvent(
                            id: b.id,
                            title: b.title,
                            mediaURL: b.mediaURL,
                            storeId: b.storeId,
                            likeCount: c,
                            createdAt: b.createdAt
                        )
                    }
                }
                for try await item in group {
                    if let item { ranked.append(item) }
                }
            }

            // 3) 좋아요 수 내림차순, 동률이면 최근 생성순(또는 updatedAt로 바꿔도 됨)
            ranked.sort {
                if $0.likeCount != $1.likeCount { return $0.likeCount > $1.likeCount }
                let l = $0.createdAt ?? .distantPast
                let r = $1.createdAt ?? .distantPast
                return l > r
            }

            // 4) 상위 N개
            self.events = Array(ranked.prefix(topN))
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}

//// 어디 공용 파일에 두고 쓰세요.
//func safeURL(from raw: String?) -> URL? {
//    guard var s = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
//          !s.isEmpty else { return nil }
//
//    // 흔한 실수: 백슬래시 이스케이프가 섞여 있을 때
//    s = s.replacingOccurrences(of: "\\/", with: "/")
//
//    // 1차 시도
//    if let u = URL(string: s) { return u }
//
//    // 한글/공백 등 인코딩 시도
//    // #, %, / 는 유지하고 나머지만 인코딩
//    var allowed = CharacterSet.urlQueryAllowed
//    allowed.insert(charactersIn: "#%/")
//    if let enc = s.addingPercentEncoding(withAllowedCharacters: allowed),
//       let u2 = URL(string: enc) {
//        return u2
//    }
//    return nil
//}
