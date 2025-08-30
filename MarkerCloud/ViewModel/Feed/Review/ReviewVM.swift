//
//  ReviewVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

private struct ReviewItemDTO: Decodable {
    let reviewContent: String
    let reviewImageUrl: String?
    let reviewScore: Double
    let createAt: String
}

private struct ReviewListDTO: Decodable {
    let avgScore: Double
    let reviewList: [ReviewItemDTO]
}

private struct ReviewResponse: Decodable {
    let responseDto: ReviewListDTO
    let error: String?
    let success: Bool
}

struct ReviewUI: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let imageURL: URL?
    let score: Double
    let createdAt: Date?
}

@MainActor
final class ReviewVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var avgScore: Double = 0
    @Published var reviews: [ReviewUI] = []
    
    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private func log(_ items: Any...) {
            print("[ReviewVM]", items.map { "\($0)" }.joined(separator: " "))
        }
        private func prettyJSON(_ data: Data) -> String? {
            guard let obj = try? JSONSerialization.jsonObject(with: data),
                  let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
                  let s = String(data: d, encoding: .utf8) else { return nil }
            return s
        }
    func fetch(feedId: Int) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("feed")
            .appendingPathComponent(String(feedId))
            .appendingPathComponent("reviews")
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        do {
            log("GET", url.absoluteString)
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("status:", code)
            
            if let pretty = prettyJSON(data) {
                            log("↩︎ JSON\n\(pretty)")
                        } else if let raw = String(data: data, encoding: .utf8) {
                            log("↩︎ RAW\n\(raw.prefix(512))")
                        } else {
                            log("↩︎ <binary \(data.count) bytes>")
                        }
            
            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                log("실패:", errorMessage!)
                return
            }
            
            
            let decoded = try JSONDecoder().decode(ReviewResponse.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                log("실패:", errorMessage!)
                return
            }
            
            avgScore = decoded.responseDto.avgScore
            reviews = decoded.responseDto.reviewList.map { dto in
                ReviewUI(
                    content: dto.reviewContent,
                    imageURL: URL(string: dto.reviewImageUrl ?? ""),
                    score: dto.reviewScore,
                    createdAt: Self.parseDate(dto.createAt)
                )
            }
            log("성공 | avgScore:", avgScore, "| reviews:", reviews.count)
        } catch let DecodingError.keyNotFound(key, ctx) {
            errorMessage = "디코딩 실패(key): \(key.stringValue) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        } catch let DecodingError.typeMismatch(type, ctx) {
            errorMessage = "디코딩 실패(type): \(type) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        } catch let DecodingError.valueNotFound(type, ctx) {
            errorMessage = "디코딩 실패(value): \(type) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        } catch let DecodingError.dataCorrupted(ctx) {
            errorMessage = "디코딩 실패(data): \(ctx.debugDescription)"
        } catch {
            errorMessage = error.localizedDescription
            log("네트워크/기타 에러:", error.localizedDescription)
        }
    }
    
    // 여러 형식 시도해서 Date로 파싱
    private static func parseDate(_ s: String) -> Date? {
        // 1) ISO8601 (밀리초/오프셋 포함해도 대부분 커버)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        
        // 2) 일반적인 형태들 추가 시도
        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        for f in fmts {
            let df = DateFormatter()
            df.locale = .init(identifier: "ko_KR")
            df.timeZone = .init(secondsFromGMT: 0)
            df.dateFormat = f
            if let d = df.date(from: s) { return d }
        }
        return nil
    }
}
