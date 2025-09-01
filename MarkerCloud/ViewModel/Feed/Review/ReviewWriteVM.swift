//
//  ReviewPostVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class ReviewWriteVM: ObservableObject {
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var done = false
    @Published var uploadedImageURL: URL?

    func submit(
        feedId: String,
        userId: String,
        content: String,
        rating: Double,
        image: UIImage?
    ) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        done = false
        uploadedImageURL = nil
        defer { isSubmitting = false }

        do {
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw NSError(domain: "ReviewWriteVM", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "리뷰 내용을 입력해 주세요."])
            }
            guard (0...5).contains(rating) else {
                throw NSError(domain: "ReviewWriteVM", code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "평점은 0.0 ~ 5.0 범위여야 합니다."])
            }

            let db = Firestore.firestore()
            let subRef  = db.collection("feeds").document(feedId)
                           .collection("reviews").document(userId)
            let rootRef = db.collection("reviews")
                           .document("\(feedId)_\(userId)")
            let batch = db.batch()

            // 1) 기존 문서 존재 여부 확인 (createdAt 제어용)
            let snap = try await rootRef.getDocument()
            let exists = snap.exists

            // 2) 이미지가 있다면 Storage에 업로드
            var imageURLString: String?
            if let image {
                imageURLString = try await uploadImage(image, feedId: feedId, userId: userId)
                if let s = imageURLString { self.uploadedImageURL = URL(string: s) }
            }

            // 3) 저장 payload
            var payload: [String: Any] = [
                "userId": userId,
                "feedId": feedId,
                "content": trimmed,
                "rating": rating,
            ]
            if let imageURLString { payload["imageURL"] = imageURLString }

            if exists {
              payload["updatedAt"] = FieldValue.serverTimestamp()
              batch.setData(payload, forDocument: subRef, merge: true)
              batch.setData(payload, forDocument: rootRef, merge: true)
            } else {
              var createPayload = payload
              createPayload["createdAt"] = FieldValue.serverTimestamp()
              batch.setData(createPayload, forDocument: subRef, merge: true)
              batch.setData(createPayload, forDocument: rootRef, merge: true)
            }

            try await batch.commit()
            done = true
        } catch {
            errorMessage = error.localizedDescription
            done = false
        }
    }

    // Storage에 리뷰 이미지 업로드 후 public download URL 반환
    private func uploadImage(_ image: UIImage, feedId: String, userId: String) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "ReviewWriteVM", code: -10,
                          userInfo: [NSLocalizedDescriptionKey: "이미지 인코딩 실패"])
        }
        let ref = Storage.storage()
            .reference()
            .child("reviews/\(feedId)/\(userId)/image.jpg")
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: meta)

        // 업로드 직후 URL이 늦게 반영되는 경우가 드물게 있어 재시도 로직을 간단히 넣어줌
        for attempt in 1...5 {
            do {
                let url = try await ref.downloadURL()
                return url.absoluteString
            } catch {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
                if attempt == 5 { throw error }
            }
        }
        throw NSError(domain: "ReviewWriteVM", code: -11,
                      userInfo: [NSLocalizedDescriptionKey: "이미지 URL을 가져오지 못했습니다."])
    }

    func reset() {
        isSubmitting = false
        errorMessage = nil
        done = false
        uploadedImageURL = nil
    }
}
