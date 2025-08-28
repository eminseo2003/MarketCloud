//
//  SearchResultVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct StoreRow: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imgURL: URL?
}
struct ProductRow: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let mediaURL: URL?
    let likeCount: Int?
}
struct EventRow: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let mediaURL: URL?
    let likeCount: Int?
}

private struct StoreItemDTO: Decodable {
    let storeName: String
    let imgUrl: String?
}
private struct ProductItemDTO: Decodable {
    let productName: String
    let mediaUrl: String?
    let like_count: Int?
}
private struct EventItemDTO: Decodable {
    let eventName: String
    let mediaUrl: String?
    let like_count: Int?
}

private struct CombinedContainerDTO: Decodable {
    let stores: [StoreItemDTO]?
    let products: [ProductItemDTO]?
    let events: [EventItemDTO]?
}
private struct CombinedResponse: Decodable {
    let responseDto: CombinedContainerDTO
    let error: String?
    let success: Bool
}

private struct StoreSearchContainerDTO: Decodable { let searchResult: [StoreItemDTO] }
private struct StoreSearchResponse: Decodable {
    let responseDto: StoreSearchContainerDTO
    let error: String?
    let success: Bool
}
private struct ProductSearchContainerDTO: Decodable { let searchResult: [ProductItemDTO] }
private struct ProductSearchResponse: Decodable {
    let responseDto: ProductSearchContainerDTO
    let error: String?
    let success: Bool
}
private struct EventSearchContainerDTO: Decodable { let searchResult: [EventItemDTO] }
private struct EventSearchResponse: Decodable {
    let responseDto: EventSearchContainerDTO
    let error: String?
    let success: Bool
}

@MainActor
final class SearchResultVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var stores: [StoreRow] = []
    @Published var products: [ProductRow] = []
    @Published var events: [EventRow] = []

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
    private func log(_ items: Any...) {
        print("[SearchResultVM]", items.map { "\($0)" }.joined(separator: " "))
    }

    func fetch(keyword: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? keyword
        let url = base.appendingPathComponent("api")
            .appendingPathComponent("search")
            .appendingPathComponent(encoded)

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

            if let combined = try? JSONDecoder().decode(CombinedResponse.self, from: data), combined.success {
                if let s = combined.responseDto.stores {
                    self.stores = s.map { StoreRow(name: $0.storeName, imgURL: URL(string: $0.imgUrl ?? "")) }
                } else { self.stores = [] }

                if let p = combined.responseDto.products {
                    self.products = p.map {
                        ProductRow(name: $0.productName, mediaURL: URL(string: $0.mediaUrl ?? ""), likeCount: $0.like_count)
                    }
                } else { self.products = [] }

                if let e = combined.responseDto.events {
                    self.events = e.map {
                        EventRow(name: $0.eventName, mediaURL: URL(string: $0.mediaUrl ?? ""), likeCount: $0.like_count)
                    }
                } else { self.events = [] }

                log("parsed (combined) -> stores:", stores.count, "products:", products.count, "events:", events.count)
                return
            }

            var parsed = false

            if let s = try? JSONDecoder().decode(StoreSearchResponse.self, from: data), s.success {
                self.stores = s.responseDto.searchResult.map { StoreRow(name: $0.storeName, imgURL: URL(string: $0.imgUrl ?? "")) }
                parsed = true
            }
            if let p = try? JSONDecoder().decode(ProductSearchResponse.self, from: data), p.success {
                self.products = p.responseDto.searchResult.map {
                    ProductRow(name: $0.productName, mediaURL: URL(string: $0.mediaUrl ?? ""), likeCount: $0.like_count)
                }
                parsed = true
            }
            if let e = try? JSONDecoder().decode(EventSearchResponse.self, from: data), e.success {
                self.events = e.responseDto.searchResult.map {
                    EventRow(name: $0.eventName, mediaURL: URL(string: $0.mediaUrl ?? ""), likeCount: $0.like_count)
                }
                parsed = true
            }

            if parsed {
                log("parsed (single) -> stores:", stores.count, "products:", products.count, "events:", events.count)
            } else {
                errorMessage = "응답 파싱 실패"
                log("parse error: unknown schema")
            }
        } catch {
            errorMessage = error.localizedDescription
            log("network error:", error.localizedDescription)
        }
    }
}
