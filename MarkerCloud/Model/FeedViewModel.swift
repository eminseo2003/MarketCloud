//
//  FeedViewModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var feeds: [Feed] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchFeeds(marketId: Int) async {
        guard let url = URL(string: "https://famous-blowfish-plainly.ngrok-free.app/api/feed/\(marketId)") else {
            print("❌ 잘못된 URL: marketId=\(marketId)")
            return
        }
        
        print("🌐 [FeedViewModel] 요청 시작: \(url.absoluteString)")
        isLoading = true
        defer {
            isLoading = false
            print("✅ [FeedViewModel] 요청 종료")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpRes = response as? HTTPURLResponse {
                print("📡 응답 코드: \(httpRes.statusCode)")
            }
            
            let decoded = try JSONDecoder().decode([Feed].self, from: data)  // ✅ 바로 배열 디코딩
            feeds = decoded
            print("🎉 [FeedViewModel] 피드 불러오기 성공: \(feeds.count)개")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [FeedViewModel] 네트워크/디코딩 에러: \(error.localizedDescription)")
        }
    }
}
