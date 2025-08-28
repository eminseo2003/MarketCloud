//
//  SearchRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

private struct SearchRankItemDTO: Decodable {
    let rank: Int
    let searchName: String
}

private struct SearchRankListDTO: Decodable {
    let rankings: [SearchRankItemDTO]
}

@MainActor
final class SearchRankVM: ObservableObject {
    @Published var keywords: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var apiURL: URL { base.appendingPathComponent("api/trend/") }

    func fetch(limit: Int = 5) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        var req = URLRequest(url: apiURL)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            rlog("SearchRankVM", "GET", apiURL.absoluteString)
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            rlog("SearchRankVM", "status:", code)
            if let p = prettyJSON(data) { rlog("SearchRankVM", "JSON\n\(p)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(RankResponse<SearchRankListDTO>.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                return
            }

            self.keywords = decoded.responseDto.rankings
                .sorted { $0.rank < $1.rank }
                .prefix(limit)
                .map { $0.searchName }

            rlog("SearchRankVM", "loaded:", keywords.count, "|", keywords.joined(separator: ", "))
        } catch {
            errorMessage = error.localizedDescription
            rlog("SearchRankVM", "error:", error.localizedDescription)
        }
    }
}
