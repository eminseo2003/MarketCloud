//
//  Feed.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct FeedResponse: Codable {
    let responseDto: FeedListDto
    let error: String?
    let success: Bool
}

struct FeedListDto: Codable {
    let feedList: [Feed]
}

struct Feed: Codable, Identifiable {
    var id: Int { feedId }
    let feedId: Int
    let storeName: String
    let storeImageUrl: String
    let createdAt: String
    let feedContent: String
    let feedImageUrl: String
    let feedType: String
    let feedLikeCount: String
}

