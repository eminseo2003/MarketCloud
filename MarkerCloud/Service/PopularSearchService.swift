//
//  PopularSearchService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/3/25.
//

import Foundation
import FirebaseFirestore

enum PopularSearchService {
    static let col = Firestore.firestore().collection("popularKeywords")

    // 키워드 정규화: 소문자, 앞뒤 공백 제거, 슬래시 등 위험문자 치환
    static func normalize(_ raw: String) -> String {
        let lowered = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // Firestore 문서 id에 안전하게: 슬래시 등은 하이픈으로 치환
        let unsafe = CharacterSet(charactersIn: "/#?.[]$")
        return lowered.unicodeScalars.map { unsafe.contains($0) ? "-" : Character($0) }.map(String.init).joined()
    }

    // 검색 시 호출: 해당 키워드 count + 1 (없으면 생성)
    static func increment(keyword raw: String) async throws {
        let shown = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !shown.isEmpty else { return }

        let id = normalize(shown)
        let ref = col.document(id)

        try await ref.setData([
            "keyword": shown,
            "count": FieldValue.increment(Int64(1)),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    // 상위 N개(기본 5개) 인기 검색어 가져오기
    static func fetchTop(limit: Int = 5) async -> [PopularKeyword] {
        do {
            let snap = try await col
                .order(by: "count", descending: true)      // count 내림차순
                .order(by: "updatedAt", descending: true)  // 동률이면 최근 업데이트 우선(선택)
                .limit(to: limit)
                .getDocuments()

            return snap.documents.compactMap { doc in
                // keyword/count 누락 방지용 수동 파싱
                let data = doc.data()
                guard let keyword = data["keyword"] as? String,
                      let count   = data["count"] as? Int else {
                    return nil
                }
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                return PopularKeyword(keyword: keyword, count: count, updatedAt: updatedAt)
            }
        } catch {
            print("[PopularSearchService] fetchTop error:", error.localizedDescription)
            return []
        }
    }

    // 상위 5개 전용 헬퍼
    static func fetchTop5() async -> [PopularKeyword] {
        await fetchTop(limit: 5)
    }
}

