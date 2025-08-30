//
//  EventRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

private struct EventRankItemDTO: Decodable {
    let feedId: Int
    let rank: Int
    let eventName: String
    let imgUrl: String
    let like_count: Int
}
private struct EventRankListDTO: Decodable {
    let rankings: [EventRankItemDTO]
}

struct PopularEvent: Identifiable, Hashable {
    let id = UUID()
    let feedId: Int
    let rank: Int
    let name: String
    let imageURL: URL?
    let likeCount: Int
}

@MainActor
final class EventRankVM: ObservableObject {
    @Published var events: [PopularEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    private var url: URL { base.appendingPathComponent("api/trend/event") }

    func fetch() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            print("[EventRankVM] GET \(url.absoluteString)")
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            print("[EventRankVM] status:", code)
            if let p = prettyJSON(data) { print("[EventRankVM] ↩︎ JSON\n\(p)") }

            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }

            let decoded = try JSONDecoder().decode(RankResponse<EventRankListDTO>.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                return
            }

            events = decoded.responseDto.rankings.map {
                PopularEvent(
                    feedId: $0.feedId,
                    rank: $0.rank,
                    name: $0.eventName,
                    imageURL: safeURL(from: $0.imgUrl),
                    likeCount: $0.like_count
                )
            }
            print("[EventRankVM] loaded:", events.count)
        } catch {
            errorMessage = error.localizedDescription
            print("[EventRankVM] 에러", error.localizedDescription)
        }
    }
}
// 어디 공용 파일에 두고 쓰세요.
func safeURL(from raw: String?) -> URL? {
    guard var s = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
          !s.isEmpty else { return nil }

    // 흔한 실수: 백슬래시 이스케이프가 섞여 있을 때
    s = s.replacingOccurrences(of: "\\/", with: "/")

    // 1차 시도
    if let u = URL(string: s) { return u }

    // 한글/공백 등 인코딩 시도
    // #, %, / 는 유지하고 나머지만 인코딩
    var allowed = CharacterSet.urlQueryAllowed
    allowed.insert(charactersIn: "#%/")
    if let enc = s.addingPercentEncoding(withAllowedCharacters: allowed),
       let u2 = URL(string: enc) {
        return u2
    }
    return nil
}
