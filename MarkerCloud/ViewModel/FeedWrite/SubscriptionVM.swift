//
//  SubscriptionVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class SubscriptionVM: ObservableObject {
    @Published var isSubscribe = false          // 내가 이 점포를 구독 중인지
    @Published var subscriptionCount = 0        // 이 점포의 총 구독자 수
    @Published var isBusy = false               // 중복 탭 방지용
    @Published var errorMessage: String?

    private var countListener: ListenerRegistration?
    
    func start(storeId: String, userId: String?) {
        stop()
        guard !storeId.isEmpty else { return }
        
        countListener = Subscription.collection
            .whereField("storeId", isEqualTo: storeId)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { self.errorMessage = err.localizedDescription; return }
                self.subscriptionCount = snap?.documents.count ?? 0
            }

        Task {
            if let uid = userId ?? Auth.auth().currentUser?.uid, !uid.isEmpty {
                await refreshIsSubscribed(storeId: storeId, userId: uid)
            } else {
                isSubscribe = false
            }
        }
    }

    func stop() {
        countListener?.remove(); countListener = nil
    }

    // 단건 조회로 현재 내가 구독 중인지 확인
    func refreshIsSubscribed(storeId: String, userId: String) async {
        do {
            let docId = "\(storeId)-\(userId)"
            let snap = try await Subscription.collection.document(docId).getDocument()
            self.isSubscribe = snap.exists
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // 토글 (구독/해제)
    func toggle(storeId: String, userId: String) async {
        guard !isBusy else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let docId = "\(storeId)-\(userId)"
            let ref = Subscription.collection.document(docId)

            if isSubscribe {
                // 구독 해제
                try await ref.delete()
                isSubscribe = false
            } else {
                // 구독
                try await ref.setData([
                    "userId": userId,
                    "storeId": storeId,
                    "createdAt": FieldValue.serverTimestamp()
                ], merge: false)
                isSubscribe = true
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // 명시적 구독
    func subscribe(storeId: String, userId: String) async {
        guard !isBusy else { return }
        isBusy = true; errorMessage = nil
        defer { isBusy = false }
        do {
            let docId = "\(storeId)-\(userId)"
            try await Subscription.collection.document(docId).setData([
                "userId": userId,
                "storeId": storeId,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: false)
            isSubscribe = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 명시적 구독 해제
    func unsubscribe(storeId: String, userId: String) async {
        guard !isBusy else { return }
        isBusy = true; errorMessage = nil
        defer { isBusy = false }
        do {
            let docId = "\(storeId)-\(userId)"
            try await Subscription.collection.document(docId).delete()
            isSubscribe = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

