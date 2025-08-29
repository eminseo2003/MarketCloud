//
//  MarketRecommendVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import Combine

private struct MarketRecommendRequest: Encodable {
    let q1: String
    let q2: String
    let q3: String
    let q4: [String]

    enum CodingKeys: String, CodingKey { case q1, q2, q3, q4 }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(q1, forKey: .q1)
        try c.encode(q2, forKey: .q2)
        try c.encode(q3, forKey: .q3)
        if q4.count == 1, let only = q4.first {
            try c.encode(only, forKey: .q4)
        } else {
            try c.encode(q4, forKey: .q4)
        }
    }
}

struct MarketRecommendDTO: Decodable {
    let top1Market: String
    let marketAddress: String
}

struct MarketRecommendResponse: Decodable {
    let responseDto: MarketRecommendDTO?
    let error: FlexibleError?
    let success: Bool
}

@MainActor
final class MarketRecommendVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var result: MarketRecommendDTO?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var apiURL: URL {
        base.appendingPathComponent("api/market/recommend/", isDirectory: false)
    }

    private func log(_ items: Any...) {
        print("[MarketRecommendVM]", items.map { "\($0)" }.joined(separator: " "))
    }

    func recommend(q1: String, q2: String, q3: String, q4: [String]) async {
        errorMessage = nil
        result = nil

        log("POST /market/recommend q1=\(q1) q2=\(q2) q3=\(q3) q4=\(q4)")

        var req = URLRequest(url: apiURL)
        req.httpMethod = "POST"
        req.timeoutInterval = 15
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            req.httpBody = try JSONEncoder().encode(
                MarketRecommendRequest(q1: q1, q2: q2, q3: q3, q4: q4)
            )
        } catch {
            errorMessage = "요청 인코딩 실패: \(error.localizedDescription)"
            log("\(errorMessage!)")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1

            // ② 상태코드
            log("status:", status)

            guard (200...299).contains(status) else {
                errorMessage = "HTTP \(status)"
                log("실패:", errorMessage!)
                return
            }

            let res = try JSONDecoder().decode(MarketRecommendResponse.self, from: data)

            guard res.success, let dto = res.responseDto else {
                errorMessage = res.error?.text ?? "추천 결과를 찾을 수 없습니다."
                log("실패:", errorMessage!)
                return
            }

            self.result = dto
            log("성공:", dto.top1Market, "|", dto.marketAddress)

        } catch {
            errorMessage = error.localizedDescription
            log("네트워크/디코딩 에러:", error.localizedDescription)
        }
    }
}
