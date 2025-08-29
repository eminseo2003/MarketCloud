//
//  FeedLikeVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/29/25.
//

import Foundation

private struct LikeToggleRequest: Encodable { let userId: Int }
private struct LikeToggleDTO: Decodable { let isLiked: Bool; let likesCount: Int }
private struct LikeToggleResponse: Decodable {
    let responseDto: LikeToggleDTO?
    let error: Int?
    let success: Bool
}

struct LikeToggleResult { let isLiked: Bool; let likesCount: Int }

@MainActor
final class FeedLikeVM: ObservableObject {
    @Published private(set) var loadingFeedIds: Set<Int> = []
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    private func log(_ items: Any...) {
        print("[FeedLikeVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }

    enum PayloadStyle: String, CaseIterable {
        case jsonTop
        case jsonWrapped
        case formURLEncoded
        case jsonSnake
    }

    func toggle(feedId: Int, userId: Int) async -> LikeToggleResult? {
        errorMessage = nil
        guard userId > 0 else {
            errorMessage = "로그인이 필요합니다."
            return nil
        }

        loadingFeedIds.insert(feedId)
        defer { loadingFeedIds.remove(feedId) }

        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("feed")
            .appendingPathComponent(String(feedId))
            .appendingPathComponent("like")

        for style in PayloadStyle.allCases {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

            switch style {
            case .jsonTop:
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                let body = ["userId": userId]
                req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            case .jsonWrapped:
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                let body = ["requestDto": ["userId": userId]]
                req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            case .formURLEncoded:
                req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                let s = "userId=\(userId)"
                req.httpBody = s.data(using: .utf8)

            case .jsonSnake:
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                let body = ["user_id": userId]
                req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
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
                    if code == 422, let raw = String(data: data, encoding: .utf8),
                       raw.contains("\"userId\"") && raw.contains("Field required") {
                        continue
                    }
                    errorMessage = "HTTP \(code)"
                    return nil
                }

                let dec = JSONDecoder()
                dec.keyDecodingStrategy = .convertFromSnakeCase
                let res = try dec.decode(LikeToggleResponse.self, from: data)
                guard res.success, let dto = res.responseDto else {
                    errorMessage = "토글 실패 (error: \(res.error ?? -1))"
                    return nil
                }
                return LikeToggleResult(isLiked: dto.isLiked, likesCount: dto.likesCount)

            } catch {
                errorMessage = error.localizedDescription
                return nil
            }
        }

        errorMessage = "요청 포맷을 서버가 인정하지 않았습니다."
        return nil
    }

    func isLoading(feedId: Int) -> Bool { loadingFeedIds.contains(feedId) }
}
