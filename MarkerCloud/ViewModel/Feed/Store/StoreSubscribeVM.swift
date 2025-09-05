//
//  StoreSubscribeVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import Foundation

// MARK: - DTO
private struct SubscribeToggleRequest: Encodable { let userId: Int }
private struct SubscribeToggleDTO: Decodable {
    // 서버가 비어있는 객체 {}를 줄 수도 있어 optional 처리
    let isSubscribed: Bool?
    let followersCount: Int?
}
private struct SubscribeToggleResponse: Decodable {
    let responseDto: SubscribeToggleDTO?
    let error: Int?
    let success: Bool
}

// 외부로 노출할 결과 타입 (필드도 optional로 전달)
struct SubscribeToggleResult {
    let isSubscribed: Bool?
    let followersCount: Int?
}

@MainActor
final class StoreSubscribeVM: ObservableObject {
    @Published private(set) var loadingStoreIds: Set<Int> = []
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    // 로그 유틸
    private func log(_ items: Any...) {
        print("[StoreSubscribeVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }

    // 요청 바디 폼 폴백 (userId 키만 변형)
    enum PayloadStyle: String, CaseIterable {
        case jsonTop        // {"userId": 43}
        case jsonWrapped    // {"requestDto":{"userId":43}}
        case formURLEncoded // userId=43
        case jsonSnake      // {"user_id": 43}
    }

    /// 구독/구독해제 토글
    func toggle(storeId: Int, userId: Int) async -> SubscribeToggleResult? {
        errorMessage = nil
        guard userId > 0 else {
            errorMessage = "로그인이 필요합니다."
            return nil
        }

        loadingStoreIds.insert(storeId)
        defer { loadingStoreIds.remove(storeId) }

        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("stores")
            .appendingPathComponent("subscribe")
            .appendingPathComponent(String(storeId))

        for style in PayloadStyle.allCases {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

            switch style {
            case .jsonTop:
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: ["userId": userId], options: [])

            case .jsonWrapped:
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: ["requestDto": ["userId": userId]], options: [])

            case .formURLEncoded:
                req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = "userId=\(userId)".data(using: .utf8)

            case .jsonSnake:
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: ["user_id": userId], options: [])
            }

            log("POST", url.absoluteString, "| style:", style.rawValue)
            if let body = req.httpBody, let s = String(data: body, encoding: .utf8) {
                log("→ body:", s)
            }

            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
                log("status:", code)
                if let pretty = prettyJSON(data) { log("↩︎ JSON\n\(pretty)") }

                if !(200...299).contains(code) {
                    // 422 & "userId field required"면 다음 스타일로 재시도
                    if code == 422, let raw = String(data: data, encoding: .utf8),
                       raw.contains("\"userId\"") && raw.contains("Field required") {
                        continue
                    }
                    errorMessage = "HTTP \(code)"
                    return nil
                }

                let dec = JSONDecoder()
                dec.keyDecodingStrategy = .convertFromSnakeCase // followers_count 대비
                let res = try dec.decode(SubscribeToggleResponse.self, from: data)

                guard res.success else {
                    errorMessage = "구독 토글 실패 (error: \(res.error ?? -1))"
                    return nil
                }

                let dto = res.responseDto
                return SubscribeToggleResult(
                    isSubscribed: dto?.isSubscribed,
                    followersCount: dto?.followersCount
                )

            } catch {
                errorMessage = error.localizedDescription
                return nil
            }
        }

        errorMessage = "요청 포맷을 서버가 인정하지 않았습니다."
        return nil
    }

    func isLoading(storeId: Int) -> Bool { loadingStoreIds.contains(storeId) }
}
