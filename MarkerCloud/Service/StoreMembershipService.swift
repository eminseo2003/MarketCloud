//
//  StoreMembershipService.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum StoreMembershipService {
    static func userHasStore(in marketId: Int, ownerId: String) async -> Bool {
        do {
            let db = Firestore.firestore()
            let snap = try await db.collection("stores")
                .whereField("createdBy", isEqualTo: ownerId)
                .whereField("marketId", isEqualTo: marketId)
                .limit(to: 1)
                .getDocuments()
            print("[MembershipService] query count =", snap.documents.count)
            return !snap.documents.isEmpty
        } catch {
            print("[MembershipService] query error:", error)
            return false
        }
    }
}


