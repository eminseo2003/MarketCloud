//
//  Feed.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

enum PromoKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case store, product, event
    var id: String { rawValue }
}

enum MediaType: String, Codable, CaseIterable, Identifiable, Hashable {
    case image, video
    var id: String { rawValue }
}

//struct Feed: Identifiable, Codable, Hashable {
//    var id: String = UUID().uuidString
//    
//    var storeId: UUID
//    
//    var promoKind: PromoKind
//    var mediaType: MediaType
//    var title: String
//    var prompt: String
//    var mediaUrl: URL
//    var body: String
//    var createdAt: Date
//    
//    var isVideo: Bool { mediaType == .video }
//    var isImage: Bool { mediaType == .image }
//    
//    var event: EventFeedPayload?
//    var storeInfo: StoreFeedPayload?
//    var product: ProductFeedPayload?
//    
//    var reviews: [Review] = []
//    
//    var averageRating: Double {
//        guard !reviews.isEmpty else { return 0 }
//        return Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
//    }
//}

struct FeedResponse: Codable {
    let responseDto: FeedListDto
    let error: String?
    let success: Bool
}

struct FeedListDto: Codable {
    let feedList: [Feed]
}

struct Feed: Codable, Identifiable {
    var id: Int { feedid }
    let feedid: Int
    let storeid: Int
    let promoKind: String
    let mediaType: String?      // null일 수도 있음
    let mediaUrl: String       // null일 수도 있음
    let prompt: String?         // 없을 수도 있음
    let body: String?           // 없을 수도 있음
    let created_at: String
}

