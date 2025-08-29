//
//  FeedUploadVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation
import UIKit

@MainActor
final class StoreFeedGenerateVM: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    @Published var done = false
    @Published var generated: GenerateDTO?
    
    // 토글: 필요 시 로그 끄기
    private let enableLog = true
    private func log(_ items: Any...) {
        guard enableLog else { return }
        let msg = items.map { "\($0)" }.joined(separator: " ")
        print("[FeedUploadVM]", msg)
    }
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let str = String(data: pretty, encoding: .utf8) else { return nil }
        return str
    }
    
    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var generateURL: URL {
        base.appendingPathComponent("api")
            .appendingPathComponent("feed")
            .appendingPathComponent("generate")
    }
    
    // ✅ mediaType이 "image"든 "video"든, 이미지는 늘 storeImage로 보냄
    func uploadStoreFeed(
        feedType: String,          // "store" | "product" | "event"
        mediaType: String,         // "image" | "video"
        userId: Int,
        storeDescription: String,
        image: UIImage
    ) async {
        let t0 = CFAbsoluteTimeGetCurrent()
        log("▶️ uploadStoreFeed(image) called",
            "| feedType:", feedType, "| mediaType:", mediaType,
            "| userId:", userId, "| descLen:", storeDescription.count)
        
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            errorMessage = "이미지 인코딩 실패"
            log("❌ 이미지 인코딩 실패")
            return
        }
        log("📦 image data size:", data.count, "bytes")
        
        let ft = feedType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let mt = mediaType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        await uploadStoreFeed(
            feedType: ft,
            mediaType: mt,
            userId: userId,
            storeDescription: storeDescription,
            mediaData: data,
            fileName: "image.jpg",
            mimeType: "image/jpeg"
        )
        
        log("⏱️ elapsed:", String(format: "%.3f s", CFAbsoluteTimeGetCurrent() - t0))
    }
    
    // 공통(Data) 버전 (이미지/동영상 모두 지원) — 이미지 파일은 storeImage로 첨부
    func uploadStoreFeed(
        feedType: String,
        mediaType: String,
        userId: Int,
        storeDescription: String,
        mediaData: Data,
        fileName: String,
        mimeType: String
    ) async {
        let t0 = CFAbsoluteTimeGetCurrent()
        var req = URLRequest(url: generateURL)
        req.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        // 입력 파라미터 로그
        log("🌐 POST", generateURL.absoluteString)
        log("🔖 headers:", ["Content-Type": "multipart/form-data; boundary=\(boundary)",
                            "ngrok-skip-browser-warning": "1"])
        log("📝 fields → feedType:", feedType, "| mediaType:", mediaType,
            "| userId:", userId, "| descLen:", storeDescription.count)
        log("📎 file → name:", fileName, "| mime:", mimeType, "| size:", mediaData.count, "bytes")
        
        var body = Data()
        func addField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        func addFieldNumber(_ name: String, _ value: Int) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        let allowedFT = ["store","product","event"]
        let allowedMT = ["image","video"]
        guard allowedFT.contains(feedType) else { errorMessage = "feedType 값이 올바르지 않습니다."; log("❌ invalid feedType:", feedType); return }
        guard allowedMT.contains(mediaType) else { errorMessage = "mediaType 값이 올바르지 않습니다."; log("❌ invalid mediaType:", mediaType); return }
        
        // 텍스트 필드
        addField("feedType", feedType)
        addField("mediaType", mediaType)
        addFieldNumber("userId", userId)
        addField("storeDescription", storeDescription)
        
        // 파일(이미지는 항상 storeImage로 첨부)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"storeImage\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(mediaData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        req.httpBody = body
        log("📤 payload size:", body.count, "bytes")
        
        isUploading = true
        defer {
            isUploading = false
            log("⏱️ elapsed:", String(format: "%.3f s", CFAbsoluteTimeGetCurrent() - t0))
        }
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("📡 status:", code)
            
            if let pretty = prettyJSON(data) {
                log("↩︎ JSON response:\n\(pretty)")
            } else {
                log("↩︎ raw response:", String(data: data, encoding: .utf8) ?? "<binary \(data.count) bytes>")
            }
            
            guard (200..<300).contains(code) else {
                errorMessage = "업로드 실패 (status \(code))"
                log("⚠️ 업로드 실패:", errorMessage ?? "")
                return
            }
            do {
                let res = try JSONDecoder().decode(GenerateResponse.self, from: data)
                if res.success {
                    self.generated = res.responseDto
                    self.done = true
                    log("✅ 업로드 성공 | mediaUrl:", res.responseDto.feedMediaUrl)
                } else {
                    self.errorMessage = res.error ?? "응답 파싱 실패"
                    log("⚠️ 서버 실패:", self.errorMessage ?? "")
                }
            } catch {
                self.errorMessage = "응답 파싱 실패: \(error.localizedDescription)"
                log("⚠️ 디코딩 실패:", self.errorMessage ?? "")
            }
        } catch {
            errorMessage = error.localizedDescription
            log("❌ 네트워크 에러:", error.localizedDescription)
        }
    }
}
