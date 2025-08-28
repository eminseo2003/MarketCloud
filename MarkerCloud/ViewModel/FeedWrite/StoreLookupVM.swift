//
//  StoreLookupVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct StoreLookupDTO: Decodable {
    let categoryId: Int
    let phoneNumber: String
    let weekdayStart: String
    let weekdayEnd: String
    let weekendStart: String
    let weekendEnd: String
    let paymentMethods: [String]
    let address: String
}

struct StoreLookupResponse: Decodable {
    let responseDto: StoreLookupDTO?
    let error: Int?
    let success: Bool
}

@MainActor
final class StoreLookupVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var store: StoreLookupDTO?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    private func apiURL(for storeName: String) -> URL {
        return base.appendingPathComponent("api/store").appendingPathComponent(storeName)
    }

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
    private func log(_ items: Any...) { print("[StoreLookupVM]", items.map { "\($0)" }.joined(separator: " ")) }

    func fetch(by storeName: String) async {
        errorMessage = nil
        store = nil
        isLoading = true
        defer { isLoading = false }

        let url = apiURL(for: storeName)
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
            else { log("↩︎ bytes:", data.count) }

            guard (200...299).contains(code) else {
                if code == 404 {
                    errorMessage = "점포를 찾을 수 없습니다."
                } else {
                    errorMessage = "HTTP \(code)"
                }
                return
            }

            guard !data.isEmpty else {
                errorMessage = "응답이 비어 있습니다."
                return
            }

            let decoded = try JSONDecoder().decode(StoreLookupResponse.self, from: data)
            guard decoded.success else {
                errorMessage = "서버 오류(\(decoded.error ?? -1))"
                return
            }

            guard let dto = decoded.responseDto else {
                errorMessage = "점포 정보를 찾을 수 없습니다."
                return
            }

            self.store = dto
            log("loaded store:", storeName,
                "| categoryId:", dto.categoryId,
                "| phoneNumber:", dto.phoneNumber,
                "| weekdayStart:", dto.weekdayStart,
                "| weekdayEnd:", dto.weekdayEnd,
                "| weekendStart:", dto.weekendStart,
                "| weekendEnd:", dto.weekendEnd,
                "| paymentMethods:", dto.paymentMethods,
                "| address:", dto.address
            )

        } catch {
            errorMessage = error.localizedDescription
            log("error:", error.localizedDescription)
        }
    }
}
