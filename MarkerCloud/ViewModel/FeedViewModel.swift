//
//  FeedViewModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation

struct Feed: Codable, Identifiable {
    var id: Int { feedId }
    let feedId: Int
    let storeName: String
    let storeImageUrl: String
    let createdAt: String
    let feedTitle: String
    let feedContent: String
    let feedImageUrl: String
    let feedType: String
    let feedLikeCount: Int
    let feedReviewCount: Int
}

private struct FeedListContainer: Decodable {
    let feedList: [Feed]
}
private struct FeedListResponse: Decodable {
    let responseDto: FeedListContainer
    let error: String?
    let success: Bool
}

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var feeds: [Feed] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchFeeds(marketId: Int) async {
        guard let url = URL(string: "https://famous-blowfish-plainly.ngrok-free.app/api/feed/\(marketId)") else {
            print("잘못된 URL: marketId=\(marketId)")
            return
        }

        print("[FeedViewModel] 요청 시작:", url.absoluteString)
        isLoading = true
        defer {
            isLoading = false
            print("[FeedViewModel] 요청 종료")
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse { print("[FeedViewModel] 응답 코드:", http.statusCode) }

            if let wrapped = try? JSONDecoder().decode(FeedListResponse.self, from: data),
               wrapped.success {
                self.feeds = wrapped.responseDto.feedList
                print("[FeedViewModel] 피드 불러오기 성공(래핑): \(feeds.count)개")
                return
            }

            if let direct = try? JSONDecoder().decode([Feed].self, from: data) {
                self.feeds = direct
                print("[FeedViewModel] 피드 불러오기 성공(직접 배열): \(feeds.count)개")
                return
            }

            errorMessage = "응답 파싱 실패"
            if let s = String(data: data, encoding: .utf8) {
                print("[FeedViewModel] 파싱 실패. 원본:", s)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("[FeedViewModel] 네트워크/디코딩 에러:", error.localizedDescription)
        }
    }
}
