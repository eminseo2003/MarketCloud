//
//  KeywordVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import Foundation

// MARK: - DTO

private struct KeywordItemDTO: Decodable {
    let keyword: String
}

private struct KeywordListDTO: Decodable {
    let keywordList: [KeywordItemDTO]
}

private struct KeywordResponse: Decodable {
    let responseDto: KeywordListDTO?
    let error: FlexibleError?
    let success: Bool
}

// MARK: - ViewModel

@MainActor
final class KeywordVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var keywords: [String] = []     // UI 에 바로 쓰기 좋은 형태

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    func fetch() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("keyword")

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

            let res = try JSONDecoder().decode(KeywordResponse.self, from: data)
            guard res.success, let dto = res.responseDto else {
                errorMessage = res.error?.text ?? "서버 응답 오류"
                return
            }

            // 중복/공백 정리
            let list = dto.keywordList
                .map { $0.keyword.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            self.keywords = Array(NSOrderedSet(array: list)) as? [String] ?? list
            log("✅ loaded keywords:", self.keywords.joined(separator: ", "))

        } catch {
            errorMessage = error.localizedDescription
            log("❌", error.localizedDescription)
        }
    }

    // MARK: - Log helpers
    private func log(_ items: Any...) {
        print("[KeywordVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
}
