//
//  MarketListVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct MarketItemDTO: Decodable {
    let marketCode: String
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

// UI에 쓰기 편한 카드 모델 (Asset 이름 포함)
struct MarketCardUI: Identifiable, Hashable {
    let id = UUID()
    let code: String
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

    private let assetMap: [String: String] = [
        "MKT001": "market1",
        "MKT002": "market2",
        "MKT003": "market3",
        "MKT004": "market4"
    ]
    private let defaultAsset = "market_default"
    
        func assetName(forMarketName name: String) -> String {
            markets.first { $0.name == name }?.imageAssetName ?? defaultAsset
        }

        func marketCode(forMarketName name: String) -> String {
            markets.first { $0.name == name }?.code ?? ""
        }

    private func assetName(for code: String) -> String {
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
                        log("• code:", m.marketCode,
                            "| name:", m.marketName,
                            "| asset:", assetName(for: m.marketCode))
                    }
            self.markets = decoded.responseDto.marketList.map {
                MarketCardUI(code: $0.marketCode,
                             name: $0.marketName,
                             imageAssetName: assetName(for: $0.marketCode))
            }
            log("loaded:", markets.count)
        } catch {
            errorMessage = error.localizedDescription
            log("error:", error.localizedDescription)
        }
    }
}
