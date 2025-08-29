//
//  KeywordMarketVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import Foundation

// MARK: - DTO

private struct KeywordMarketDTO: Decodable {
    let marketName: String
    let description: String
}

private struct KeywordMarketResponse: Decodable {
    let responseDto: KeywordMarketDTO?
    let error: FlexibleError?
    let success: Bool
}

// MARK: - UI Model (원하면 바로 사용)
struct KeywordMarketUI: Hashable {
    let marketName: String
    let description: String
}

// MARK: - ViewModel

@MainActor
final class KeywordMarketVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var result: KeywordMarketUI?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    func fetch(keywordName: String) async {
        errorMessage = nil
        result = nil
        isLoading = true
        defer { isLoading = false }

        // 경로 컴포넌트 안전 처리
        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("keyword")
            .appendingPathComponent(keywordName)

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            log("GET", url.absoluteString)
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("status:", code)
            if let pretty = prettyJSON(data) { log("↩︎ JSON\n\(pretty)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(KeywordMarketResponse.self, from: data)
            guard decoded.success, let dto = decoded.responseDto else {
                errorMessage = decoded.error?.text ?? "서버 응답 오류"
                return
            }

            result = KeywordMarketUI(
                marketName: dto.marketName,
                description: dto.description
            )
            log("name:", dto.marketName)

        } catch {
            errorMessage = error.localizedDescription
            log("error:", error.localizedDescription)
        }
    }

    // MARK: - helpers
    private func log(_ items: Any...) {
        print("[KeywordMarketVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
}
