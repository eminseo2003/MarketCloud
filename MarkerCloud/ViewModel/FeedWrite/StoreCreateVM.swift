//
//  StoreCreateVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// 점포 생성(파이어스토어 + 스토리지 업로드) 뷰모델
final class StoreCreateVM: ObservableObject {
    @Published var isLoading = false
    @Published var done = false
    @Published var errorMessage: String?
    
    @MainActor
    func createStore(
        storeName: String,
        categoryId: Int,
        phoneNumber: String?,
        weekdayStart: Date?,
        weekdayEnd: Date?,
        weekendStart: Date?,
        weekendEnd: Date?,
        address: String?,
        paymentMethods: [String],
        storeDescript: String?,
        marketId: Int? = nil,
        image: UIImage? = nil,
        ownerId: String,
        userDocId: String
    ) async {
        isLoading = true
        errorMessage = nil
        done = false
        
        // 현재 로그인 세션(디버깅용 로그)
        let authUid = Auth.auth().currentUser?.uid
        print("[StoreCreateVM] createStore() auth.currentUser=\(authUid ?? "nil"), ownerId=\(ownerId), userDocId=\(userDocId)")
        
        do {
            // 2) 파이어스토어 핸들 & 새 점포 문서 ID 생성
            let db = Firestore.firestore()
            let storeId = UUID().uuidString
            
            // 3) 선택된 이미지가 있으면 Firebase Storage에 업로드
            var profileImageURL: String?
            if let image, let data = image.jpegData(compressionQuality: 0.85) {
                let ref = Storage.storage().reference()
                    .child("stores/\(storeId)/profile.jpg")
                let meta = StorageMetadata()
                meta.contentType = "image/jpeg"
                _ = try await ref.putDataAsync(data, metadata: meta)
                profileImageURL = try await ref.downloadURL().absoluteString
            }
            
            //파이어스토어에 저장할 payload 구성
            var payload: [String: Any] = [
                "id": storeId,
                "storeName": storeName,
                "categoryId": categoryId,
                "paymentMethods": paymentMethods,
                "createdBy": ownerId,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            if let phoneNumber { payload["phoneNumber"] = phoneNumber }
            if let address { payload["address"] = address }
            if let storeDescript { payload["storeDescript"] = storeDescript }
            if let marketId { payload["marketId"] = marketId }
            if let weekdayStart { payload["weekdayStart"] = Timestamp(date: weekdayStart) }
            if let weekdayEnd { payload["weekdayEnd"] = Timestamp(date: weekdayEnd) }
            if let weekendStart { payload["weekendStart"] = Timestamp(date: weekendStart) }
            if let weekendEnd { payload["weekendEnd"] = Timestamp(date: weekendEnd) }
            if let profileImageURL { payload["profileImageURL"] = profileImageURL }
            
            //stores/{storeId} 문서 생성
            let storeRef = db.collection("stores").document(storeId)
            try await storeRef.setData(payload)
            
            //users/{userDocId} 문서의 storeIds 배열에 이번 storeId 추가(merge)
            let userRef = db.collection("users").document(userDocId)
            try await userRef.setData([
                "storeIds": FieldValue.arrayUnion([storeId]),
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
            
            await MainActor.run {
                isLoading = false
                done = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

