//
//  UserStoreService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum UserStoreService {
    static func userOwnsStore(
        storeId: String,
        uid: String? = Auth.auth().currentUser?.uid
    ) async -> Bool {
        guard let uid = uid, !storeId.isEmpty else { return false }
        do {
            let snap = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            guard let arr = snap.data()?["storeIds"] as? [String] else { return false }
            return arr.contains(storeId)
        } catch {
            print("[UserStoreService] read error:", error)
            return false
        }
    }
}
