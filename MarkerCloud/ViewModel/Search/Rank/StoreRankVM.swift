//
//  StoreRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct PopularStore: Identifiable, Hashable {
    let id = UUID()
    let rank: Int
    let name: String
    let imageURL: URL?
}

private struct StoreRankItemDTO: Decodable {
    let rank: Int
    let storeName: String
    let imgUrl: String
}
private struct StoreRankListDTO: Decodable {
    let rankings: [StoreRankItemDTO]
}

@MainActor
final class StoreRankVM: ObservableObject {
    @Published var stores: [PopularStore] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var url: URL { base.appendingPathComponent("api/trend/store") }

    func fetch() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            print("[StoreRankVM] GET \(url.absoluteString)")
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            print("[StoreRankVM] status:", code)
            if let p = prettyJSON(data) { print("[StoreRankVM] ↩︎ JSON\n\(p)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(RankResponse<StoreRankListDTO>.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                return
            }

            stores = decoded.responseDto.rankings.map {
                PopularStore(
                    rank: $0.rank,
                    name: $0.storeName,
                    imageURL: URL(string: $0.imgUrl)
                )
            }
            print("[StoreRankVM] loaded:", stores.count)
        } catch {
            errorMessage = error.localizedDescription
            print("[StoreRankVM] 에러:", error.localizedDescription)
        }
    }
}
