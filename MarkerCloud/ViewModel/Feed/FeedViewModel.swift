////
////  FeedViewModel.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/27/25.
////
//
//import Foundation
//
////struct Feed: Identifiable, Hashable {
////    let id: Int
////    let storeId: Int
////    let storeName: String
////    let storeImageURL: URL?
////    let createdAt: Date
////    let title: String
////    let content: String
////    let imageURL: URL
////    let feedType: String
////    var likeCount: Int
////    let reviewCount: Int
////    var isLiked: Bool
////}
//
//private struct FeedItemDTO: Decodable {
//    let feedId: Int
//    let storeId: Int
//    let storeName: String
//    let storeImageUrl: String?
//    let createdAt: String
//    let feedTitle: String
//    let feedContent: String
//    let feedImageUrl: String
//    let feedType: String
//    let feedLikeCount: Int
//    let feedReviewCount: Int
//    let isLiked: Bool
//}
//private struct FeedListDTO: Decodable {
//    let feedList: [FeedItemDTO]
//}
//
//private struct FeedListResponse: Decodable {
//    let responseDto: FeedListDTO?
//    let error: String?
//    let success: Bool
//}
//
//@MainActor
//final class FeedViewModel: ObservableObject {
//    @Published var feeds: [Feed] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
//
//    //private func makeURL(marketId: Int) -> URL {
//    private func makeURL(marketId: Int, userId: Int) -> URL {
//        base.appendingPathComponent("api")
//            .appendingPathComponent("feed")
//            .appendingPathComponent(String(marketId))
//            .appendingPathComponent(String(userId))
//    }
//    //func fetch(marketId: Int) async {
//    func fetch(marketId: Int, userId: Int) async {
//        errorMessage = nil
//        isLoading = true
//        defer { isLoading = false }
//
//        //let url = makeURL(marketId: marketId)
//        let url = makeURL(marketId: marketId, userId: userId)
//        var req = URLRequest(url: url)
//        req.httpMethod = "GET"
//        req.setValue("application/json", forHTTPHeaderField: "Accept")
//        req.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
//
//        do {
//            log("GET", url.absoluteString)
//            let (data, resp) = try await URLSession.shared.data(for: req)
//            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
//            log("status:", code)
//            if let pretty = prettyJSON(data) { log("↩︎ JSON\n\(pretty)") }
//
//            guard (200...299).contains(code) else {
//                errorMessage = "HTTP \(code)"
//                return
//            }
//
//            let decoded = try JSONDecoder().decode(FeedListResponse.self, from: data)
//            guard decoded.success, let dto = decoded.responseDto else {
//                errorMessage = decoded.error ?? "서버 응답 오류"
//                return
//            }
//
//            self.feeds = dto.feedList.map { item -> Feed in
////                let storeImgURL: URL? = item.storeImageUrl?
////                    .trimmingCharacters(in: .whitespacesAndNewlines)
////                    .flatMap { s in
////                                URL(string: s.trimmingCharacters(in: .whitespacesAndNewlines))
////                            }
////                
////                let mainImgURL: URL = urlFrom(
////                    item.feedImageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
////                )
//                let storeImgURL = urlOpt(from: item.storeImageUrl)
//                let mainImgURL  = urlOpt(from: item.feedImageUrl) ?? fallbackURL
//                return Feed(
//                        id: item.feedId,
//                        storeId: item.storeId,
//                        storeName: item.storeName,
//                        storeImageURL: storeImgURL,
//                        createdAt: parseAPIDate(item.createdAt),
//                        title: item.feedTitle,
//                        content: item.feedContent,
//                        imageURL: mainImgURL,
//                        feedType: item.feedType,
//                        likeCount: item.feedLikeCount,
//                        reviewCount: item.feedReviewCount,
//                        isLiked: item.isLiked
//                    )
//            }
//            log("loaded feeds:", feeds.count)
//
//        } catch {
//            errorMessage = error.localizedDescription
//            log("error:", error.localizedDescription)
//        }
//    }
//    private func urlOpt(from s: String?) -> URL? {
//        guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
//        return URL(string: t)
//    }
//
//    
//
//    private let fallbackURL = URL(string: "https://example.com/")!
//
//    private func urlFrom(_ s: String) -> URL {
//        URL(string: s) ?? fallbackURL
//    }
//
//    private func parseAPIDate(_ s: String) -> Date {
//        let iso = ISO8601DateFormatter()
//        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        if let d = iso.date(from: s) { return d }
//        iso.formatOptions = [.withInternetDateTime]
//        if let d = iso.date(from: s) { return d }
//
//        let fmts = [
//            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
//            "yyyy-MM-dd'T'HH:mm:ssZ",
//            "yyyy-MM-dd HH:mm:ss"
//        ]
//        let df = DateFormatter()
//        df.locale = Locale(identifier: "en_US_POSIX")
//        for f in fmts {
//            df.dateFormat = f
//            if let d = df.date(from: s) { return d }
//        }
//        return Date()
//    }
//
//    private func prettyJSON(_ data: Data) -> String? {
//        guard let obj = try? JSONSerialization.jsonObject(with: data),
//              let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
//              let s = String(data: d, encoding: .utf8) else { return nil }
//        return s
//    }
//
//    private func log(_ items: Any...) {
//        print("[FeedViewModel]", items.map { "\($0)" }.joined(separator: " "))
//    }
//}
