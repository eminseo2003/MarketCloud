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
    static func userHasStore(in marketId: Int, uid: String? = Auth.auth().currentUser?.uid) async -> Bool {
        guard let uid else { return false }
        do {
            let db = Firestore.firestore()
            let snap = try await db.collection("stores")
                .whereField("createdBy", isEqualTo: uid)
                .whereField("marketId", isEqualTo: marketId)
                .limit(to: 1)
                .getDocuments()
            return !snap.documents.isEmpty
        } catch {
            print("hasStore query error:", error)
            return false
        }
    }
}
