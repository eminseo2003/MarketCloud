//
//  ReviewVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

private struct ReviewItemDTO: Decodable {
    let reviewContent: String
    let reviewImageUrl: String?
    let reviewScore: Double
    let createAt: String
}

private struct ReviewListDTO: Decodable {
    let avgScore: Double
    let reviewList: [ReviewItemDTO]
}

private struct ReviewResponse: Decodable {
    let responseDto: ReviewListDTO
    let error: String?
    let success: Bool
}

struct ReviewUI: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let imageURL: URL?
    let score: Double
    let createdAt: Date?
}

@MainActor
final class ReviewVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var avgScore: Double = 0
    @Published var reviews: [ReviewUI] = []
    
    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    
    func fetch(feedId: Int) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        let url = base
            .appendingPathComponent("api")
            .appendingPathComponent("review")
            .appendingPathComponent(String(feedId))
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else {
                errorMessage = "HTTP \(code)"
                return
            }
            
            let decoded = try JSONDecoder().decode(ReviewResponse.self, from: data)
            guard decoded.success else {
                errorMessage = decoded.error ?? "서버 오류"
                return
            }
            
            avgScore = decoded.responseDto.avgScore
            reviews = decoded.responseDto.reviewList.map { dto in
                ReviewUI(
                    content: dto.reviewContent,
                    imageURL: URL(string: dto.reviewImageUrl ?? ""),
                    score: dto.reviewScore,
                    createdAt: Self.parseDate(dto.createAt)
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // 여러 형식 시도해서 Date로 파싱
    private static func parseDate(_ s: String) -> Date? {
        // 1) ISO8601 (밀리초/오프셋 포함해도 대부분 커버)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        
        // 2) 일반적인 형태들 추가 시도
        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        for f in fmts {
            let df = DateFormatter()
            df.locale = .init(identifier: "ko_KR")
            df.timeZone = .init(secondsFromGMT: 0)
            df.dateFormat = f
            if let d = df.date(from: s) { return d }
        }
        return nil
    }
}
