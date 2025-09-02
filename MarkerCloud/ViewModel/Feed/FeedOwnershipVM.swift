//
//  FeedOwnershipVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FeedOwnershipVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOwner = false   // 이 피드가 내 것인가?

    // feedId와 현재 로그인 사용자 id 로 소유 여부 판단
    func load(feedId: String, ownerId: String) async {
        isLoading = true
        errorMessage = nil
        isOwner = false

        let db = Firestore.firestore()
        defer { isLoading = false }

        do {
            // 1) feeds/{feedId} 조회
            let feedSnap = try await db.collection("feeds").document(feedId).getDocument()
            guard let feed = feedSnap.data() else {
                errorMessage = "피드를 찾을 수 없습니다."
                return
            }

            // 1-1) 우선 feed.userId 로 판단
            if let feedCreator = feed["userId"] as? String {
                isOwner = (feedCreator == ownerId)
                if isOwner { return }
            }

            // 1-2) 폴백: storeId → stores/{storeId}.createdBy 비교
            if let storeId = feed["storeId"] as? String, !storeId.isEmpty {
                let storeSnap = try await db.collection("stores").document(storeId).getDocument()
                if let store = storeSnap.data(),
                   let createdBy = store["createdBy"] as? String {
                    isOwner = (createdBy == ownerId)
                } else {
                    isOwner = false
                }
            } else {
                // storeId 도 없으면 소유 아님으로 처리
                isOwner = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 여러 피드에 대해 일괄 판단이 필요할 때 사용할 수 있는 헬퍼 (옵션)
    func loadIfMine(feedId: String, ownerId: String) async -> Bool {
        await loadAndReturn(feedId: feedId, ownerId: ownerId)
    }

    private func loadAndReturn(feedId: String, ownerId: String) async -> Bool {
        let db = Firestore.firestore()
        do {
            let feedSnap = try await db.collection("feeds").document(feedId).getDocument()
            guard let feed = feedSnap.data() else { return false }
            if let feedCreator = feed["userId"] as? String { return feedCreator == ownerId }
            if let storeId = feed["storeId"] as? String, !storeId.isEmpty {
                let storeSnap = try await db.collection("stores").document(storeId).getDocument()
                if let store = storeSnap.data(),
                   let createdBy = store["createdBy"] as? String { return createdBy == ownerId }
            }
            return false
        } catch {
            return false
        }
    }
}
