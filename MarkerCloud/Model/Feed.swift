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

struct Feed: Identifiable, Codable, Hashable {
    var id: UUID
    
    var storeId: UUID
    var isPublished: Bool
    
    var promoKind: PromoKind
    var mediaType: MediaType
    var title: String //점포명/상품명/이벤트명
    var prompt: String //AI에 넣을 프롬프트
    var mediaUrl: URL //사용자가 입력한 사진
    var body: String //사용자가 입력한 줄글
    var createdAt: Date
    
    var isVideo: Bool { mediaType == .video }
    var isImage: Bool { mediaType == .image }
    
    var event: EventFeedPayload?
    var storeInfo: StoreFeedPayload?
    var product: ProductFeedPayload?
    
    var reviews: [Review] = []
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
    }
}

