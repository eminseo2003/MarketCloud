//
//  FeedUploadVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFunctions
import FirebaseCore

struct GenerateDTO: Identifiable, Hashable {
    let id: String            // feedId
    let feedMediaUrl: String  // 업로드된 사용자 입력 이미지 URL
    let feedBody: String      // 생성된(또는 입력값 기반) 본문
}

@MainActor
final class StoreFeedGenerateVM: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    @Published var generated: GenerateDTO?

    let functions = Functions.functions(region: "asia-northeast3")

    func uploadStoreFeed(
        feedType: FeedType,
        mediaType: MediaType,
        userId: String,
        storeId: String,
        marketId: Int,
        title: String,
        storeDescription: String,
        image: UIImage
    ) async {
        guard !isUploading else { return }
        isUploading = true
        errorMessage = nil
        generated = nil

        do {
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let feedId = UUID().uuidString
            let promoKind = Self.toPromoKind(feedType).rawValue
            let mediaKind = mediaType.rawValue

            // 1) 이미지 업로드
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                throw NSError(domain: "StoreFeedGenerateVM", code: -10,
                              userInfo: [NSLocalizedDescriptionKey: "이미지 인코딩 실패"])
            }
            let inputRef = storage.reference().child("feeds/\(feedId)/input.jpg")
            let meta = StorageMetadata(); meta.contentType = "image/jpeg"
            _ = try await inputRef.putDataAsync(data, metadata: meta)
            let inputImageURL = try await downloadURLWithRetry(ref: inputRef)

            // 2) 프롬프트
            let prompt = """
            다음 점포 소개 글과 이미지를 바탕으로 매력적인 점포 홍보 피드를 생성해 주세요.
            - 점포명: \(title)
            - 점포설명(사용자 입력): \(storeDescription)
            - 참고 이미지: \(inputImageURL.absoluteString)
            산뜻하고 간결한 톤으로 2~4문장으로 작성해 주세요.
            """

            // 3) AI 호출 (Cloud Functions)
            let ai = try await generateWithAI(
                title: title,
                description: storeDescription,
                inputImageURL: inputImageURL,
                mediaType: mediaType,
                marketId: marketId,
                userId: userId,
                storeId: storeId
            )
            let aiBody = ai.body
            let aiImageURL = ai.imageURL

            // 4) 배치 쓰기: /feeds, /stores/{storeId}/feeds, /stores.feedIds
            let batch = db.batch()

            let feedRef = db.collection("feeds").document(feedId)
            let storeRef = db.collection("stores").document(storeId)
            let storeFeedRef = storeRef.collection("feeds").document(feedId)

            // /feeds/{feedId} 전체 문서
            let feedPayload: [String: Any] = [
                "id": feedId,
                "storeId": storeId,
                "isPublished": false,
                "promoKind": promoKind,
                "mediaType": mediaKind,
                "title": title,
                "prompt": prompt,
                "mediaUrl": inputImageURL.absoluteString,
                "body": aiBody,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                "marketId": marketId,
                "userId": userId,
                "storeInfo": [
                    "description": aiBody,
                    "imgUrl": aiImageURL.absoluteString
                ]
            ]
            batch.setData(feedPayload, forDocument: feedRef)

            // /stores/{storeId}/feeds/{feedId} 서브컬렉션(요약본)
            let storeFeedPayload: [String: Any] = [
                "id": feedId,
                "storeId": storeId,
                "isPublished": false,
                "promoKind": promoKind,
                "mediaType": mediaKind,
                "title": title,
                "prompt": prompt,
                "mediaUrl": inputImageURL.absoluteString,
                "body": aiBody,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                "marketId": marketId,
                "userId": userId,
                "storeInfo": [
                    "description": aiBody,
                    "imgUrl": aiImageURL.absoluteString
                ]
            ]
            batch.setData(storeFeedPayload, forDocument: storeFeedRef)

            // 5) 커밋
            try await batch.commit()

            // 6) UI용 DTO
            generated = GenerateDTO(
                id: feedId,
                feedMediaUrl: inputImageURL.absoluteString,
                feedBody: aiBody
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isUploading = false
    }

    private func downloadURLWithRetry(ref: StorageReference) async throws -> URL {
        for attempt in 1...5 {
            do {
                return try await ref.downloadURL()
            } catch {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            }
        }
        throw NSError(domain: "StoreFeedGenerateVM", code: -30,
                      userInfo: [NSLocalizedDescriptionKey: "다운로드 URL을 가져오지 못했습니다."])
    }

    private func generateWithAI(
        title: String,
        description: String,
        inputImageURL: URL,
        mediaType: MediaType,
        marketId: Int,
        userId: String,
        storeId: String
    ) async throws -> (body: String, imageURL: URL) {
        let params: [String: Any] = [
            "title": title,
            "description": description,
            "inputImageUrl": inputImageURL.absoluteString,
            "mediaType": mediaType.rawValue,
            "marketId": marketId,
            "userId": userId,
            "storeId": storeId
        ]
        let result = try await functions.httpsCallable("generateStoreFeed").call(params)
        guard
            let dict = result.data as? [String: Any],
            let ok = dict["ok"] as? Bool, ok,
            let body = dict["body"] as? String,
            let imageUrlStr = dict["imageUrl"] as? String,
            let imageURL = URL(string: imageUrlStr)
        else {
            throw NSError(domain: "StoreFeedGenerateVM", code: -20,
                          userInfo: [NSLocalizedDescriptionKey: "AI 응답 파싱 실패"])
        }
        return (body, imageURL)
    }

    private static func toPromoKind(_ t: FeedType) -> PromoKind {
        switch "\(t)".lowercased() {
        case "store":   return .store
        case "product": return .product
        case "event":   return .event
        default:        return .store
        }
    }
}
