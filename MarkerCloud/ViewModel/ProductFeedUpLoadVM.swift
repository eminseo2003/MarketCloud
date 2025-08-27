//
//  FeedUploadVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation
import UIKit

@MainActor
final class ProductFeedUpLoadVM: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    @Published var done = false
    
    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var publishURL: URL {
        base.appendingPathComponent("api")
            .appendingPathComponent("feed")
    }
    
    private let enableLog = true
    private func log(_ items: Any...) {
        guard enableLog else { return }
        print("[ProductFeedUpLoadVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    
    func uploadStoreFeed( // ← 요청한 시그니처 이름 그대로
        feedType: String,
        mediaType: String,
        storeId: Int,
        productName: String,
        categoryId: Int,
        productDescription: String,
        productImage: UIImage,
        feedMediaUrl: String,
        feedBody: String
    ) async {
        log("▶️ post start | feedType:", feedType,
            "| mediaType:", mediaType,
            "| storeId:", storeId,
            "| name:", productName,
            "| categoryId:", categoryId)
        
        // 1) UIImage → JPEG Data
        guard let dataImg = productImage.jpegData(compressionQuality: 0.9) else {
            errorMessage = "이미지 인코딩 실패"
            log("❌ 이미지 인코딩 실패")
            return
        }
        
        // 2) URLRequest 구성
        var req = URLRequest(url: publishURL)
        req.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // ngrok 경고 우회 (필요 없으면 제거)
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        // 3) multipart/form-data 바디 생성
        var body = Data()
        func addField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 3-1) 텍스트 필드 (서버 키명과 일치해야 함)
        addField("feedType", feedType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        addField("mediaType", mediaType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        addField("storeId", String(storeId))
        addField("productName", productName)
        addField("categoryId", String(categoryId))
        addField("productDescription", productDescription)
        addField("feedMediaUrl", feedMediaUrl) // 생성 결과 URL
        addField("feedBody", feedBody)         // 최종 본문
        
        // 3-2) 파일 필드 (productImage)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"productImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(dataImg)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        req.httpBody = body
        
        // 4) 네트워크 호출
        isUploading = true
        defer { isUploading = false }
        
        do {
            log("🌐 POST \(publishURL.absoluteString) | payload:", body.count, "bytes")
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("📡 status:", code)
            
            // 2xx 여부만 확인(바디 파싱 불필요 시)
            guard (200..<300).contains(code) else {
                errorMessage = "업로드 실패 (status \(code))"
                log("⚠️", errorMessage ?? "")
                return
            }
            
            done = true
            log("✅ 게시 성공")
            if let s = String(data: data, encoding: .utf8), !s.isEmpty {
                log("↩︎ server says:", s) // 필요 시 모델 만들어 파싱 가능
            }
        } catch {
            errorMessage = error.localizedDescription
            log("❌ 네트워크 에러:", error.localizedDescription)
        }
    }
}
