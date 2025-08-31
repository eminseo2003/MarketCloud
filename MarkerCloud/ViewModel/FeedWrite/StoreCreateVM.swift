//
//  StoreCreateVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import FirebaseFirestore
import FirebaseStorage


final class StoreCreateVM: ObservableObject {
    @Published var isLoading = false
    @Published var done = false
    @Published var errorMessage: String?

    /// Firestore + Storage 업로드
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
        paymentMethods: [String],   // ["온누리 상품권", ...]
        storeDescript: String?,
        marketId: Int? = nil,     // 필요 시 전달. 없으면 필드 생략
        image: UIImage? = nil       // 선택 이미지(없으면 nil)
    ) async {

        isLoading = true
        errorMessage = nil
        done = false

        // 1) 문서 id는 UUID 문자열로
        let storeId = UUID().uuidString

        // 2) 이미지가 있으면 Storage에 업로드 → downloadURL
        var profileImageURLString: String? = nil
        if let img = image, let data = img.jpegData(compressionQuality: 0.85) {
            do {
                let path = "stores/\(storeId)/profile.jpg"
                let ref = Storage.storage().reference(withPath: path)
                let meta = StorageMetadata()
                meta.contentType = "image/jpeg"

                // Firebase 10+ 는 async/await 지원
                _ = try await ref.putDataAsync(data, metadata: meta)
                let url = try await ref.downloadURL()
                profileImageURLString = url.absoluteString
            } catch {
                // 이미지 실패는 문서 생성 자체를 막진 않음
                print("Storage upload error:", error)
            }
        }

        // 3) Firestore에 저장할 payload 구성 (nil은 넣지 않기)
        var payload: [String: Any] = [
            "id": storeId,
            "storeName": storeName,
            "categoryId": categoryId,
            "payment_methods": paymentMethods,            // 문자열 그대로 저장 (간단)
            "createdAt": FieldValue.serverTimestamp()
        ]

        func put(_ key: String, _ value: Any?) {
            if let v = value { payload[key] = v }
        }

        put("phoneNumber", phoneNumber)
        put("address", address)
        put("storeDescript", storeDescript)
        put("weekdayStart", weekdayStart)
        put("weekdayEnd", weekdayEnd)
        put("weekendStart", weekendStart)
        put("weekendEnd", weekendEnd)
        put("profileImageURLString", profileImageURLString)
        if let marketId { put("marketId", marketId) }   // 필요 시만 저장

        // 4) Firestore 저장
        do {
            try await Firestore.firestore()
                .collection("stores")
                .document(storeId)
                .setData(payload)

            done = true
        } catch {
            errorMessage = "저장에 실패했어요: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
