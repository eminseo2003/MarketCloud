//
//  UserStoreService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

// UserStoreService.swift
import FirebaseAuth
import FirebaseFirestore

enum UserStoreService {
  static func userOwnsStore(
    storeId: String,
    userDocId: String? = nil,
    uid: String? = Auth.auth().currentUser?.uid
  ) async -> Bool {
    let db = Firestore.firestore()

    // 1) userDocId 우선
    if let docIdToRead = userDocId, !docIdToRead.isEmpty {
      do {
        let ref  = db.collection("users").document(docIdToRead)
        let snap = try await ref.getDocument()

        print("[DBG] users/\(docIdToRead) exists=\(snap.exists) data=\(snap.data() ?? [:])")

        if let arr = snap.data()?["storeIds"] as? [String] {
          return arr.contains(storeId)
        }
      } catch {
        print("[DBG] read by userDocId error:", error)
      }
    }

    // 2) fallback: uid 문서
    if let u = uid, !u.isEmpty {
      do {
        let ref  = db.collection("users").document(u)
        let snap = try await ref.getDocument()

        print("[DBG] users/\(u) exists=\(snap.exists) data=\(snap.data() ?? [:])")

        if let arr = snap.data()?["storeIds"] as? [String] {
          return arr.contains(storeId)
        }
      } catch {
        print("[DBG] read by uid error:", error)
      }
    }

    return false
  }
}
