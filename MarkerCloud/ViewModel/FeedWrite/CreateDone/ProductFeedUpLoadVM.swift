////
////  FeedUploadVM.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/27/25.
////
//
//import Foundation
//import UIKit
//
//@MainActor
//final class ProductFeedUpLoadVM: ObservableObject {
//    @Published var isUploading = false
//    @Published var errorMessage: String?
//    @Published var done = false
//    
//    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
//    private var publishURL: URL {
//        base.appendingPathComponent("api")
//            .appendingPathComponent("feed")
//    }
//    
//    private let enableLog = true
//    private func log(_ items: Any...) {
//        guard enableLog else { return }
//        print("[ProductFeedUpLoadVM]", items.map { "\($0)" }.joined(separator: " "))
//    }
//    
//    func uploadProductFeed(
//        feedType: String,
//        mediaType: String,
//        userId: Int,
//        productName: String,
//        categoryId: Int,
//        productDescription: String,
//        productImage: UIImage,
//        feedMediaUrl: String,
//        feedBody: String
//    ) async {
//        
//        guard let dataImg = productImage.jpegData(compressionQuality: 0.9) else {
//            errorMessage = "이미지 인코딩 실패"
//            log("이미지 인코딩 실패")
//            return
//        }
//        
//        var req = URLRequest(url: publishURL)
//        req.httpMethod = "POST"
//        let boundary = "Boundary-\(UUID().uuidString)"
//        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
//        
//        var body = Data()
//        func addField(_ name: String, _ value: String) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
//            body.append("\(value)\r\n".data(using: .utf8)!)
//        }
//        func addFieldNumber(_ name: String, _ value: Int) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
//            body.append("\(value)\r\n".data(using: .utf8)!)
//        }
//        addField("feedType", feedType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
//        addField("mediaType", mediaType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
//        addFieldNumber("userId", userId)
//        addField("productName", productName)
//        addField("categoryId", String(categoryId))
//        addField("productDescription", productDescription)
//        addField("feedMediaUrl", feedMediaUrl) // 생성 결과 URL
//        addField("feedBody", feedBody)         // 최종 본문
//        
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"productImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//        body.append(dataImg)
//        body.append("\r\n".data(using: .utf8)!)
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        req.httpBody = body
//        
//        isUploading = true
//        defer { isUploading = false }
//        
//        do {
//            let (data, resp) = try await URLSession.shared.data(for: req)
//            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
//            
//            guard (200..<300).contains(code) else {
//                errorMessage = "업로드 실패 (status \(code))"
//                return
//            }
//            
//            done = true
//            log("게시 성공")
//            if let s = String(data: data, encoding: .utf8), !s.isEmpty {
//                log("↩︎ server says:", s)
//            }
//        } catch {
//            errorMessage = error.localizedDescription
//            log("네트워크 에러:", error.localizedDescription)
//        }
//    }
//}
