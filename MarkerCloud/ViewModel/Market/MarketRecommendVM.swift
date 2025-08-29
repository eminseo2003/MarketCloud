//
//  MarketRecommendVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation


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
    let error: Int?
    let success: Bool
}

@MainActor
final class MarketRecommendVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var result: MarketRecommendDTO?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var apiURL: URL {
        base.appendingPathComponent("api")
            .appendingPathComponent("market")
            .appendingPathComponent("recommend")
            .appendingPathComponent("")
    }

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let data2 = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: data2, encoding: .utf8) else { return nil }
        return s
    }
    private func log(_ items: Any...) {
        print("[MarketRecommendVM]", items.map { "\($0)" }.joined(separator: " "))
    }

    func recommend(q1: String, q2: String, q3: String, q4: [String]) async {
        errorMessage = nil
        result = nil

        let reqBody = MarketRecommendRequest(q1: q1, q2: q2, q3: q3, q4: q4)
        log("\(q1) \(q2) \(q3) \(q4)")

        var req = URLRequest(url: apiURL)
        req.httpMethod = "POST"
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            req.httpBody = try JSONEncoder().encode(reqBody)
        } catch {
            errorMessage = "요청 인코딩 실패: \(error.localizedDescription)"
            log("인코딩 실패:", error.localizedDescription)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            log("POST \(apiURL.absoluteString)")
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse { log("status:", http.statusCode) }

            if let pretty = prettyJSON(data) { log("↩︎ JSON\n\(pretty)") }

            let dec = JSONDecoder()
            let res = try dec.decode(MarketRecommendResponse.self, from: data)

            guard res.success, let dto = res.responseDto else {
                errorMessage = "추천 실패 (error: \(res.error ?? -1))"
                log("실패:", errorMessage ?? "")
                return
            }

            self.result = dto
            log("추천 성공 | market:", dto.top1Market, "| address:", dto.marketAddress)
        } catch {
            errorMessage = error.localizedDescription
            log("네트워크/디코딩 에러:", error.localizedDescription)
        }
    }
}
