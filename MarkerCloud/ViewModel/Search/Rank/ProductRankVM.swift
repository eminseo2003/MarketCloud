//
//  ProductRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

private struct ProductRankItemDTO: Decodable {
    let feedId: Int
    let rank: Int
    let mediaUrl: String
    let productName: String
    let like_count: Int
}
private struct ProductRankListDTO: Decodable {
    let rankings: [ProductRankItemDTO]
}

struct PopularProduct: Identifiable, Hashable {
    let id = UUID()
    let feedId: Int
    let rank: Int
    let productName: String
    let imageURL: URL?
    let likeCount: Int
}

@MainActor
final class ProductRankVM: ObservableObject {
    @Published var products: [PopularProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var url: URL { base.appendingPathComponent("api/trend/product") }

    func fetch() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            print("[ProductRankVM] GET \(url.absoluteString)")
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            print("[ProductRankVM] status:", code)
            if let p = prettyJSON(data) { print("[ProductRankVM] ↩︎ JSON\n\(p)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(RankResponse<ProductRankListDTO>.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                return
            }

            products = decoded.responseDto.rankings.map {
                PopularProduct(
                    feedId: $0.feedId,
                    rank: $0.rank,
                    productName: $0.productName,
                    imageURL: URL(string: $0.mediaUrl),
                    likeCount: $0.like_count
                )
            }
            print("[ProductRankVM] loaded:", products.count)
        } catch {
            errorMessage = error.localizedDescription
            print("[ProductRankVM] 에러:", error.localizedDescription)
        }
    }
}
