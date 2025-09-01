//
//  StoreMembershipService.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// 사용자가 특정 시장(marketId)에 본인 점포가 있는지 확인하는 파이어스토어 질의 모듈
enum StoreMembershipService {
    static func userHasStore(in marketId: Int, ownerId: String) async -> Bool {
        do {
            let db = Firestore.firestore()
            // 쿼리 구성:
            // 1) createdBy 필드가 ownerId인 문서
            // 2) marketId  필드가 marketId인 문서
            // 3) 존재 확인만 필요하므로 limit(1)로 성능 최적화
            let snap = try await db.collection("stores")
                .whereField("createdBy", isEqualTo: ownerId)
                .whereField("marketId", isEqualTo: marketId)
                .limit(to: 1)
                .getDocuments()
            //반환된 문서 개수
            print("[MembershipService] query count =", snap.documents.count)
            //1개라도 있으면 true
            return !snap.documents.isEmpty
        } catch {
            print("[MembershipService] query error:", error)
            return false
        }
    }
}


