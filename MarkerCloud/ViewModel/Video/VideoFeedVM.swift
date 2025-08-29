//
//  VideoFeedVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct VideoItemUI: Identifiable, Hashable {
    let id: Int
    let storeId: Int
    let name: String
    let url: URL
    let createdAt: Date
    let content: String
    let storeImageURL: URL?
    let likeCount: Int
    let reviewCount: Int
}

private struct VideoItemDTO: Decodable {
    let videoId: Int
    let storeId: Int
    let videoName: String
    let videoUrl: String
    let createdAt: String
    let videoContent: String
    let storeImage: String?
    let videoLikeCount: Int
    let videoReviewCount: Int
}

private struct VideoListDTO: Decodable {
    let videoList: [VideoItemDTO]
}

private struct VideoResponse: Decodable {
    let responseDto: VideoListDTO
    let error: String?
    let success: Bool
}

@MainActor
final class VideoFeedVM: ObservableObject {
    @Published var videos: [VideoItemUI] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var apiURL: URL { base.appendingPathComponent("api/video/") }
    private let fallbackURL = URL(string: "https://example.com")!

    private func urlRequired(_ s: String) -> URL {
        URL(string: s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? fallbackURL
    }

    private func urlOptional(_ s: String?) -> URL? {
        guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return URL(string: t)
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
            log("GET", apiURL.absoluteString)
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            log("status:", code)
            if let pretty = prettyJSON(data) { log("↩︎ JSON\n\(pretty)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(VideoResponse.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                return
            }

            self.videos = decoded.responseDto.videoList.map { dto in
                VideoItemUI(
                    id: dto.videoId,
                    storeId: dto.storeId,
                    name: dto.videoName,
                    url: urlRequired(dto.videoUrl),
                    createdAt: parseISO(dto.createdAt) ?? Date(),
                    content: dto.videoContent,
                    storeImageURL: urlOptional(dto.storeImage),
                    likeCount: dto.videoLikeCount,
                    reviewCount: dto.videoReviewCount
                )
            }


            log("loaded videos:", videos.count)
        } catch {
            errorMessage = error.localizedDescription
            log("error:", error.localizedDescription)
        }
    }

    private func parseISO(_ s: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = f.date(from: s) { return d }
        let iso = ISO8601DateFormatter()
        return iso.date(from: s)
    }

    private func prettyJSON(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let s = String(data: d, encoding: .utf8) else { return nil }
        return s
    }

    private func log(_ items: Any...) {
        print("[VideoFeedVM]", items.map { "\($0)" }.joined(separator: " "))
    }
}

