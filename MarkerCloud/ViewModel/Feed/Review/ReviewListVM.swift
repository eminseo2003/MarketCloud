//
//  ReviewVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

@MainActor
final class ReviewListVM: ObservableObject {
    @Published var isLoading = false
    @Published var reviewsCount = 0
    @Published var errorMessage: String?
    @Published var reviews: [Review] = []
        
    var avgScore: Double {
        guard !reviews.isEmpty else { return 0 }
        let sum = reviews.reduce(0.0) { $0 + $1.rating }
        return (sum / Double(reviews.count) * 10).rounded() / 10
    }
    
    func load(feedId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        async let listTask  = ReviewService.fetchReviews(feedId: feedId, limit: 50)
        async let countTask = ReviewService.fetchReviewCount(feedId: feedId)
        
        let list  = await listTask
        let count = await countTask
        
        self.reviews = list
        self.reviewsCount = max(count, list.count)
    }
}
