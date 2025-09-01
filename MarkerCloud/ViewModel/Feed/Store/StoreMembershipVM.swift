//
//  StoreMembershipVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import OSLog
import FirebaseFirestore

// 뷰에서 “현재 로그인한 사용자가 선택한 시장에 내 점포가 있는가?”를 질의하고, 그 결과(hasStore)를 바인딩해 주는 ViewModel.
@MainActor
final class StoreMembershipVM: ObservableObject {
    @Published var hasStore = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var listener: ListenerRegistration?
    
    // 실시간 구독 시작
    func start(ownerId: String, marketId: Int) {
        stop()                      // 기존 리스너 정리
        isLoading = true
        errorMessage = nil
        
        let q = Firestore.firestore().collection("stores")
            .whereField("createdBy", isEqualTo: ownerId)
            .whereField("marketId", isEqualTo: marketId)
            .limit(to: 1)
        
        listener = q.addSnapshotListener { [weak self] snap, err in
            Task { @MainActor in
                guard let self else { return }
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    self.hasStore = false
                    self.isLoading = false
                    return
                }
                self.hasStore = !(snap?.documents.isEmpty ?? true)
                self.isLoading = false
                print("[MembershipVM] live hasStore =", self.hasStore)
            }
        }
    }
    
    // 구독 중지
    func stop() {
        print("[MembershipVM] stop")
        listener?.remove()
        listener = nil
    }
}
