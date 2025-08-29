//
//  ProductFeedUploadVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation
import UIKit

@MainActor
final class ProductFeedGenerateVM: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    @Published var done = false
    @Published var generated: GenerateDTO?
    
    // 토글: 필요 시 로그 끄기
    private let enableLog = true
    private func log(_ items: Any...) {
        guard enableLog else { return }
        let msg = items.map { "\($0)" }.joined(separator: " ")
        print("🧩 [FeedUploadVM]", msg)
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
    
    func uploadProductFeed(
        feedType: String,          // "product"
        mediaType: String,         // "image" | "video"
        userId: Int,
        productName: String,
        categoryId: Int,
        productDescription: String,
        image: UIImage
    ) async {
        let t0 = CFAbsoluteTimeGetCurrent()
        log("▶️ uploadProductFeed called | feedType:", feedType, "| mediaType:", mediaType,
            "| userId:", userId, "| name:", productName, "| categoryId:", categoryId,
            "| descLen:", productDescription.count)

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            errorMessage = "이미지 인코딩 실패"; log("❌ 이미지 인코딩 실패"); return
        }
        log("📦 image data size:", data.count, "bytes")

        var req = URLRequest(url: generateURL)
        req.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

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

        // 필드
        let ft = feedType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let mt = mediaType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        addField("feedType", ft)                           // "product"
        addField("mediaType", mt)                          // "image" | "video"
        addFieldNumber("userId", userId)
        addField("productName", productName)
        addField("productDescription", productDescription)
        addField("categoryId", String(categoryId))         // 서버 스펙에 맞춰 전송

        // 파일: productImage
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"productImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        req.httpBody = body
        log("🌐 POST \(generateURL.absoluteString)")
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
                log("⚠️ 업로드 실패:", errorMessage ?? ""); return
            }

            // GenerateResponse 디코딩 (이미 VM에 타입/프로퍼티(generated) 있어야 함)
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
