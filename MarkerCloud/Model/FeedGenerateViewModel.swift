//
//  FeedGenerateViewModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation

// API Base
//private let BASE = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

enum FeedType: String, Codable { case store, product, event }
enum MediaType: String, Codable { case image, video }

// 서버가 돌려주는 생성 결과가 Feed 하나일 수도/메시지일 수도 있어 유연 파서 준비
struct ServerMessage: Codable { let success: Bool?; let message: String? }

private func makeMultipartBody(
    boundary: String,
    fields: [String: String],
    fileField: String,
    fileName: String,
    mimeType: String,
    fileData: Data
) -> Data {
    var body = Data()

    for (k, v) in fields {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(v)\r\n".data(using: .utf8)!)
    }

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"\(fileField)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    return body
}

//
//@MainActor
//final class FeedGenerateViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var errorMessage: String?
//    @Published var created: Feed?   // 성공 시 서버가 돌려준 Feed
//
//    /// storeId: Int (명세서 요구)
//    func generateFeed(
//        feedType: FeedType,
//        mediaType: MediaType,
//        storeId: Int,
//        storeDescription: String,
//        mediaData: Data,
//        fileName: String,
//        mimeType: String   // "image/jpeg" or "video/mp4"
//    ) async {
//        guard let url = URL(string: "/api/feed/generate", relativeTo: BASE) else { return }
//
//        let boundary = "Boundary-\(UUID().uuidString)"
//        var req = URLRequest(url: url)
//        req.httpMethod = "POST"
//        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        // 명세서 필드 이름에 맞춤
//        let fields: [String: String] = [
//            "feedType": feedType.rawValue,          // "store" | "product" | "event"
//            "mediaType": mediaType.rawValue,        // "image" | "video"
//            "storeId": String(storeId),             // (int)
//            "storeDescription": storeDescription    // (string)
//        ]
//
//        // 파일 필드명도 명세서에 맞춰 "storeImage"
//        req.httpBody = makeMultipartBody(
//            boundary: boundary,
//            fields: fields,
//            fileField: "storeImage",
//            fileName: fileName,
//            mimeType: mimeType,
//            fileData: mediaData
//        )
//
//        print("🚀 [FeedGenerate] POST \(url.absoluteString)")
//        isUploading = true
//        defer { isUploading = false }
//
//        do {
//            let (data, resp) = try await URLSession.shared.data(for: req)
//            if let code = (resp as? HTTPURLResponse)?.statusCode { print("📡 status: \(code)") }
//
//            // 1) Feed로 시도
//            if let feed = try? JSONDecoder().decode(Feed.self, from: data) {
//                created = feed
//                print("✅ 생성 성공: feedid=\(feed.feedId)")
//                return
//            }
//            // 2) 메시지 형태 시도
//            if let msg = try? JSONDecoder().decode(ServerMessage.self, from: data) {
//                if msg.success == true { print("✅ 생성 성공(메시지): \(msg.message ?? "")") }
//                else { errorMessage = msg.message ?? "생성 실패"; print("⚠️ \(errorMessage!)") }
//                return
//            }
//            // 3) 디코딩 안되면 원문 출력
//            print("ℹ️ raw:", String(data: data, encoding: .utf8) ?? "<binary>")
//            errorMessage = "서버 응답 형식이 예상과 다릅니다."
//        } catch {
//            errorMessage = error.localizedDescription
//            print("❌ 업로드 실패:", error.localizedDescription)
//        }
//    }
//}
