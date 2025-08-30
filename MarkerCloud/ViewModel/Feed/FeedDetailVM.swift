//
//  FeedDetailVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import Foundation

private struct FeedDetailDTO: Decodable {
    let feedId: String
    let storeName: String
    let storeImageUrl: String?
    let createdAt: String
    let feedTitle: String
    let feedContent: String
    let feedImageUrl: String
    let feedType: String
    let feedLikeCount: Int
    let feedReviewCount: Int
}

private struct FeedDetailResponse: Decodable {
    let responseDto: FeedDetailDTO?
    let error: String?
    let success: Bool
}

// MARK: - UI Model

struct FeedDetailUI: Identifiable {
    let id: Int
    let storeName: String
    let storeImageURL: URL?
    let createdAt: Date
    let title: String
    let content: String
    let imageURL: URL
    let feedType: String
    let likeCount: Int
    let reviewCount: Int
}

// MARK: - ViewModel

@MainActor
final class FeedDetailVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var detail: FeedDetailUI?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    func fetch(feedId: Int) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("feed")
            .appendingPathComponent(String(feedId))

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

            let dec = JSONDecoder()
            let res = try dec.decode(FeedDetailResponse.self, from: data)

            guard res.success, let dto = res.responseDto else {
                errorMessage = res.error ?? "서버 응답 오류"
                return
            }

            // feedId(String) → Int 변환 실패 시 요청한 feedId로 대체
            let parsedId = Int(dto.feedId) ?? feedId

            let ui = FeedDetailUI(
                id: parsedId,
                storeName: dto.storeName,
                storeImageURL: urlOptional(dto.storeImageUrl),
                createdAt: parseAPIDate(dto.createdAt),
                title: dto.feedTitle,
                content: dto.feedContent,
                imageURL: urlRequired(dto.feedImageUrl),
                feedType: dto.feedType,
                likeCount: dto.feedLikeCount,
                reviewCount: dto.feedReviewCount
            )
            self.detail = ui
            log("성공 | id:", ui.id, "| store:", ui.storeName)

        } catch let DecodingError.keyNotFound(key, ctx) {
            errorMessage = "디코딩 실패(키 누락): \(key.stringValue) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        } catch let DecodingError.typeMismatch(type, ctx) {
            errorMessage = "디코딩 실패(타입 불일치): \(type) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Utils

    private let fallbackURL = URL(string: "https://example.com")!

    private func urlOptional(_ s: String?) -> URL? {
        guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return URL(string: t)
    }
    private func urlRequired(_ s: String) -> URL {
        URL(string: s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? fallbackURL
    }

    /// 다양한 서버 포맷을 폭넓게 지원
    private func parseAPIDate(_ s: String) -> Date {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: s) { return d }

        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",   // TZ 없는 ISO
            "yyyy-MM-dd HH:mm:ss"
        ]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for f in fmts {
            df.dateFormat = f
            if let d = df.date(from: s) { return d }
        }
        return Date()
    }

    private func log(_ items: Any...) {
        print("[FeedDetailVM]", items.map { "\($0)" }.joined(separator: " "))
    }
    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
}
