//
//  MyStoresVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/1/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class MyStoresVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var store: StoreLite?   // 단일 점포만 보관

    /// ownerId + marketId 기준으로 내 점포(최대 1개) 조회
    func load(ownerId: String, marketId: Int) async {
        isLoading = true
        errorMessage = nil
        store = nil
        do {
            let snap = try await Firestore.firestore()
                .collection("stores")
                .whereField("createdBy", isEqualTo: ownerId)
                .whereField("marketId", isEqualTo: marketId)
                .limit(to: 1)
                .getDocuments()

            if let doc = snap.documents.first {
                let id   = (doc.get("id") as? String) ?? doc.documentID
                let name = (doc.get("storeName") as? String) ?? "이름 없음"
                store = StoreLite(id: id, name: name)
            } else {
                errorMessage = "현재 시장에 등록된 내 점포가 없습니다."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
