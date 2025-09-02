//
//  FeedVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FeedVM: ObservableObject {
    @Published var storeId: String?
    @Published var isPublished: Bool?
    @Published var marketId: String?
    @Published var promoKind: String?
    @Published var mediaType: String?
    @Published var title: String?
    @Published var prompt: String?
    @Published var mediaUrl: String?
    @Published var body: String?
    @Published var createdAt: Date?
    @Published var event: EventFeedPayload?
    @Published var storeInfo: StoreFeedPayload?
    @Published var product: ProductFeedPayload?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func load(feedId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let feed = await FeedService.fetchFeed(feedId: feedId)
        self.storeId = feed.storeId
        self.isPublished = feed.isPublished
        self.marketId = feed.marketId
        self.promoKind = feed.promoKind
        self.mediaType = feed.mediaType
        self.title = feed.title
        self.prompt = feed.prompt
        self.mediaUrl = feed.mediaUrl
        self.createdAt = feed.createdAt
        self.body = feed.body
        self.event = feed.event
        self.storeInfo = feed.storeInfo
        self.product = feed.product
    }
}
