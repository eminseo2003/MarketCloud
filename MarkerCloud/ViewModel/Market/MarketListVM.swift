//
//  MarketListVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct MarketItemDTO: Decodable {
    let marketid: Int
    let marketName: String
}

struct MarketListDTO: Decodable {
    let marketList: [MarketItemDTO]
}

struct MarketListResponse: Decodable {
    let responseDto: MarketListDTO
    let error: String?
    let success: Bool
}

struct MarketCardUI: Identifiable, Hashable {
    let id = UUID()
    let code: Int
    let name: String
    let imageAssetName: String
}

@MainActor
final class MarketListVM: ObservableObject {
    @Published var markets: [MarketCardUI] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app/")!
    private var apiURL: URL {
        base.appendingPathComponent("api/market/")
    }

    private let assetMap: [Int: String] = [
        1: "market1",
        2: "market2",
        3: "market3",
        4: "market4",
        5: "market4",
        6: "market4",
        7: "market4",
        8: "market4",
        9: "market4",
        10: "market4",
        11: "market4",
        12: "market4",
        13: "market4",
        14: "market4",
        15: "market4",
        16: "market4",
        17: "market4",
        18: "market4",
        19: "market4",
        20: "market4",
    ]
    private let defaultAsset = "market_default"
    
        func assetName(forMarketName name: String) -> String {
            markets.first { $0.name == name }?.imageAssetName ?? defaultAsset
        }

    func marketCode(forMarketName name: String) -> Int {
            markets.first { $0.name == name }?.code ?? 0
        }

    private func assetName(for code: Int) -> String {
            assetMap[code] ?? defaultAsset
        }

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let data2 = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: data2, encoding: .utf8) else { return nil }
        return s
    }
    private func log(_ items: Any...) {
        print("[MarketListVM]", items.map { "\($0)" }.joined(separator: " "))
    }

    func fetch() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        var req = URLRequest(url: apiURL)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            log("GET \(apiURL.absoluteString)")
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("status:", code)
            if let pretty = prettyJSON(data) { log("↩︎ JSON\n\(pretty)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(MarketListResponse.self, from: data)
            guard decoded.success else {
                errorMessage = "서버 오류"
                return
            }
            let list = decoded.responseDto.marketList
                    log("fetched markets:", list.count)
                    for m in list {
                        log("• code:", m.marketid,
                            "| name:", m.marketName,
                            "| asset:", assetName(for: m.marketid))
                    }
            self.markets = decoded.responseDto.marketList.map {
                MarketCardUI(code: $0.marketid,
                             name: $0.marketName,
                             imageAssetName: assetName(for: $0.marketid))
            }
            log("loaded:", markets.count)
        } catch {
            errorMessage = error.localizedDescription
            log("error:", error.localizedDescription)
        }
    }
}
