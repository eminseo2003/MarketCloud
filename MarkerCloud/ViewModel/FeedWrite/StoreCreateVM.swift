//
//  StoreCreateVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct StoreCreateRequest: Encodable {
    let storeName: String
    let categoryId: Int
    let phoneNumber: String
    let weekdayStart: String
    let weekdayEnd: String
    let weekendStart: String
    let weekendEnd: String
    let address: String
    let paymentMethods: [String]
    let storeDescript: String
}

struct StoreCreateResultDTO: Decodable {}

struct StoreCreateResponse: Decodable {
    let responseDto: StoreCreateResultDTO?
    let error: String?
    let success: Bool
}

@MainActor
final class StoreCreateVM: ObservableObject {
    
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var done = false
    
    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    
    private var createURL: URL {
        base.appendingPathComponent("api/store")
    }
    
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
    
    private func log(_ items: Any...) {
        print("[StoreCreateVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    
    func createStore(
        storeName: String,
        categoryId: Int,
        phoneNumber: String,
        weekdayStart: String,
        weekdayEnd: String,
        weekendStart: String,
        weekendEnd: String,
        address: String,
        paymentMethods: [String],
        storeDescript: String
    ) async {
        errorMessage = nil
        done = false
        isSubmitting = true
        defer { isSubmitting = false }
        
        let payload = StoreCreateRequest(
            storeName: storeName,
            categoryId: categoryId,
            phoneNumber: phoneNumber,
            weekdayStart: weekdayStart,
            weekdayEnd: weekdayEnd,
            weekendStart: weekendStart,
            weekendEnd: weekendEnd,
            address: address,
            paymentMethods: paymentMethods,
            storeDescript: storeDescript
        )
        
        var req = URLRequest(url: createURL)
        req.httpMethod = "POST"
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        do {
            let body = try JSONEncoder().encode(payload)
            req.httpBody = body
            
            log("POST \(createURL.absoluteString)")
            log("payload bytes:", body.count)
            if let pretty = prettyJSON(body) { log("📝 payload JSON:\n\(pretty)") }
            
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("status:", code)
            log("resp bytes:", data.count)
            
            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                log("실패:", errorMessage!)
                return
            }
            
            guard !data.isEmpty else {
                done = true
                log("성공(본문 없음)")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(StoreCreateResponse.self, from: data)
                guard decoded.success else {
                    errorMessage = decoded.error ?? "서버 오류"
                    log("생성 실패:", errorMessage ?? "")
                    return
                }
                done = true
                log("생성 성공 (decoded)")
            } catch {
                done = true
                log("생성 성공(디코딩 생략) raw:", String(data: data, encoding: .utf8) ?? "\(data.count) bytes")
            }
            
            
        } catch {
            errorMessage = error.localizedDescription
            log("네트워크 에러:", error.localizedDescription)
        }
    }
}
