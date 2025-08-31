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
        image: UIImage? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        done = false
        
        guard let uid = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                isLoading = false
                errorMessage = "로그인이 필요합니다."
            }
            return
        }
        
        do {
            let db = Firestore.firestore()
            let storeId = UUID().uuidString
            
            var profileImageURL: String?
            if let image, let data = image.jpegData(compressionQuality: 0.85) {
                let ref = Storage.storage().reference()
                    .child("stores/\(storeId)/profile.jpg")
                let meta = StorageMetadata()
                meta.contentType = "image/jpeg"
                _ = try await ref.putDataAsync(data, metadata: meta)
                profileImageURL = try await ref.downloadURL().absoluteString
            }
            
            var payload: [String: Any] = [
                "id": storeId,
                "storeName": storeName,
                "categoryId": categoryId,
                "paymentMethods": paymentMethods,
                "createdBy": uid,
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
            
            
            let storeRef = db.collection("stores").document(storeId)
            try await storeRef.setData(payload)
            
            let userRef = db.collection("users").document(uid)
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

