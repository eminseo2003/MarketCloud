//
//  ReviewPostVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import UIKit

struct ReviewPostResponse: Decodable {
    let responseDto: EmptyDTO?
    let error: String?
    let success: Bool

    struct EmptyDTO: Decodable {}
}

@MainActor
final class ReviewPostVM: ObservableObject {
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var done = false

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    
    private func postURL(_ feedId: Int) -> URL {
        base.appendingPathComponent("api")
            .appendingPathComponent("review")
            .appendingPathComponent(String(feedId))
    }

    func submitReview(
        feedId: Int,
        userId: Int,
        reviewContent: String,
        reviewScore: Int,
        reviewImage: UIImage?
    ) async {
        let data: Data? = {
            guard let img = reviewImage else { return nil }
            return img.jpegData(compressionQuality: 0.9)
        }()

        await submitReview(
            feedId: feedId,
            userId: userId,
            reviewContent: reviewContent,
            reviewScore: Double(reviewScore),
            imageData: data,
            fileName: "review.jpg",
            mimeType: "image/jpeg"
        )
    }

    func submitReview(
        feedId: Int,
        userId: Int,
        reviewContent: String,
        reviewScore: Double,
        imageData: Data?,
        fileName: String? = nil,
        mimeType: String? = nil
    ) async {
        errorMessage = nil
        done = false
        isSubmitting = true
        defer { isSubmitting = false }

        let url = postURL(feedId)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        var body = Data()
        func addField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        addField("userId", String(userId))
        addField("reviewContent", reviewContent)
        addField("reviewScore", String(reviewScore))

        if let data = imageData, let fileName, let mimeType {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"reviewImage\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        log("POST", url.absoluteString)
        log("fields userId:", userId, "| score:", reviewScore, "| contentLen:", reviewContent.count)
        if let imageData { log("file size:", imageData.count, "bytes") }
        else { log("file: <none>") }
        log("payload:", body.count, "bytes")

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("status:", code)
            if let pretty = prettyJSON(data) { log("↩︎ JSON:\n\(pretty)") }
            else { log("↩︎ raw bytes:", data.count) }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                log("실패:", errorMessage!)
                return
            }

            if let res = try? JSONDecoder().decode(ReviewPostResponse.self, from: data), res.success {
                done = true
                log("리뷰 등록 성공")
            } else {
                done = true
                log("리뷰 등록 성공(응답 파싱 생략)")
            }
        } catch {
            errorMessage = error.localizedDescription
            log("네트워크 에러:", error.localizedDescription)
        }
    }

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
    private func log(_ items: Any...) {
        print("[ReviewPostVM]", items.map { "\($0)" }.joined(separator: " "))
    }
}
