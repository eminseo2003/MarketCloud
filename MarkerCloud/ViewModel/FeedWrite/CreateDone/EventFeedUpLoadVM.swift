//
//  FeedUploadVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation
import UIKit

@MainActor
final class EventFeedUpLoadVM: ObservableObject {
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
    private func serverDateString(_ date: Date) -> String {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(identifier: "Asia/Seoul")
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return f.string(from: date)
        }
    func uploadEventFeed(
            feedType: String,
            mediaType: String,
            userId: Int,
            eventName: String,
            eventDescription: String,
            eventStartAt: Date,
            eventEndAt: Date,
            eventImage: UIImage,
            feedMediaUrl: String,
            feedBody: String
        ) async {
            let t0 = CFAbsoluteTimeGetCurrent()
            log("▶️ post start | feedType:", feedType,
                "| mediaType:", mediaType,
                "| userId:", userId,
                "| name:", eventName,
                "| start:", serverDateString(eventStartAt),
                "| end:", serverDateString(eventEndAt))

            // 기본 유효성 체크
            let ft = feedType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard ft == "event" else {
                errorMessage = "feedType은 'event'여야 합니다. (현재: \(feedType))"
                log("잘못된 feedType:", feedType)
                return
            }
            guard eventEndAt >= eventStartAt else {
                errorMessage = "이벤트 종료 시간이 시작 시간보다 빠릅니다."
                log("잘못된 시간 범위")
                return
            }

            // 이미지 -> Data
            guard let dataImg = eventImage.jpegData(compressionQuality: 0.9) else {
                errorMessage = "이미지 인코딩 실패"
                log(" 이미지 인코딩 실패")
                return
            }
            log("image data size:", dataImg.count, "bytes")

            // URLRequest 구성
            var req = URLRequest(url: publishURL)
            req.httpMethod = "POST"
            let boundary = "Boundary-\(UUID().uuidString)"
            req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning") // ngrok 경고 우회(옵션)

            // 멀티파트 바디
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
            // 텍스트 필드들
            addField("feedType", ft)
            addField("mediaType", mediaType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
            addFieldNumber("userId", userId)
            addField("eventName", eventName)
            addField("eventDescription", eventDescription)
            addField("eventStartAt", serverDateString(eventStartAt))
            addField("eventEndAt", serverDateString(eventEndAt))
            addField("feedMediaUrl", feedMediaUrl) // 생성 결과 URL
            addField("feedBody", feedBody)         // 최종 본문

            // 파일 파트: eventImage
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"eventImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(dataImg)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            req.httpBody = body

            // 네트워크 전송
            isUploading = true
            defer {
                isUploading = false
                log("⏱️ elapsed:", String(format: "%.3f s", CFAbsoluteTimeGetCurrent() - t0))
            }

            do {
                log("🌐 POST \(publishURL.absoluteString) | payload:", body.count, "bytes")
                let (data, resp) = try await URLSession.shared.data(for: req)
                let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
                log("📡 status:", code)

                // 필요 시 서버 응답 로깅
                if let s = String(data: data, encoding: .utf8), !s.isEmpty {
                    log("↩︎ server says:", s)
                }

                // 성공 판정
                guard (200..<300).contains(code) else {
                    errorMessage = "업로드 실패 (status \(code))"
                    log("⚠️", errorMessage ?? "")
                    return
                }
                done = true
                log("게시 성공")
            } catch {
                errorMessage = error.localizedDescription
                log("네트워크 에러:", error.localizedDescription)
            }
        }
    }
