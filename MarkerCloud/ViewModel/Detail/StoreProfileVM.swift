//
//  StoreProfileVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/29/25.
//

import Foundation
import Combine

// MARK: - DTO

private struct StoreFeedPreviewDTO: Decodable {
    let mediaUrl: String?
    let feedName: String
    let likeCount: Int         // 서버 like_count → likeCount (convertFromSnakeCase 사용)
    let feedType: String
}

private struct StoreProfileDTO: Decodable {
    let storeImg: String?
    var followerCount: Int
    let totalLikedCount: Int
    let isMyStore: Bool
    var isSubscribed: Bool
    let storeDescript: String
    let storeAddress: String
    let storePhoneNumber: String
    let weekdayStart: String
    let weekdayEnd: String
    let weekendStart: String
    let weekendEnd: String
    let feeds: [StoreFeedPreviewDTO]
}

private struct StoreProfileResponse: Decodable {
    let responseDto: StoreProfileDTO?
    let error: String?
    let success: Bool
}

// MARK: - UI Model

struct StoreFeedPreviewUI: Identifiable, Hashable {
    let id = UUID()
    let mediaURL: URL?
    let name: String
    let likeCount: Int
    let type: String
}

struct StoreProfileUI: Hashable {
    let imageURL: URL?
    var followerCount: Int
    let totalLikedCount: Int
    let isMyStore: Bool
    var isSubscribed: Bool
    let description: String
    let address: String
    let phoneNumber: String
    let weekdayStart: String
    let weekdayEnd: String
    let weekendStart: String
    let weekendEnd: String
    let feeds: [StoreFeedPreviewUI]
}

// MARK: - ViewModel

@MainActor
final class StoreProfileVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profile: StoreProfileUI?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    func fetch(storeId: Int, userId: Int) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("stores")
            .appendingPathComponent("profile")
            .appendingPathComponent(String(storeId))
            .appendingPathComponent(String(userId))

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
                log("실패:", errorMessage!)
                return
            }

            let dec = JSONDecoder()
            dec.keyDecodingStrategy = .convertFromSnakeCase
            let res = try dec.decode(StoreProfileResponse.self, from: data)

            guard res.success, let dto = res.responseDto else {
                errorMessage = res.error ?? "서버 응답 오류"
                log("실패:", errorMessage!)
                return
            }

            // Map → UI
            let ui = StoreProfileUI(
                imageURL: urlOpt(dto.storeImg),
                followerCount: dto.followerCount,
                totalLikedCount: dto.totalLikedCount,
                isMyStore: dto.isMyStore,
                isSubscribed: dto.isSubscribed,
                description: dto.storeDescript,
                address: dto.storeAddress,
                phoneNumber: dto.storePhoneNumber,
                weekdayStart: dto.weekdayStart,
                weekdayEnd: dto.weekdayEnd,
                weekendStart: dto.weekendStart,
                weekendEnd: dto.weekendEnd,
                feeds: dto.feeds.map {
                    StoreFeedPreviewUI(
                        mediaURL: urlOpt($0.mediaUrl),
                        name: $0.feedName,
                        likeCount: $0.likeCount,
                        type: $0.feedType
                    )
                }
            )

            self.profile = ui
            log("✅ 성공 | feeds:", ui.feeds.count)

        } catch let DecodingError.keyNotFound(key, ctx) {
            errorMessage = "디코딩 실패(key): \(key.stringValue) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
            log("❌", errorMessage!)
        } catch let DecodingError.typeMismatch(type, ctx) {
            errorMessage = "디코딩 실패(type): \(type) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
            log("❌", errorMessage!)
        } catch let DecodingError.valueNotFound(type, ctx) {
            errorMessage = "디코딩 실패(value): \(type) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
            log("❌", errorMessage!)
        } catch let DecodingError.dataCorrupted(ctx) {
            errorMessage = "디코딩 실패(data): \(ctx.debugDescription)"
            log("❌", errorMessage!)
        } catch {
            errorMessage = error.localizedDescription
            log("❌ 네트워크/기타 에러:", error.localizedDescription)
        }
    }

    // MARK: - Utils

    private func urlOpt(_ s: String?) -> URL? {
        guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return URL(string: t)
    }

    private func log(_ items: Any...) {
        print("[StoreProfileVM]", items.map { "\($0)" }.joined(separator: " "))
    }

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }
}
