//
//  MyReviewListView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct MyReviewListView: View {
    let reviews: [Review]
    @State private var selectedReview: Review? = nil
    private func feed(forFeedId id: String) -> Feed? {
        dummyFeed.first { $0.id == id }
    }
    var body: some View {
        VStack(spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                
                List(reviews) { review in
                    Button {
                        selectedReview = review
                    } label: {
                        HStack(spacing: 10) {
                            if let imageURL = review.imageURL {
                                ReviewImage(url: imageURL)
                            } else {
                                Rectangle().fill(.clear)
                                    .frame(width: 50, height: 50)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(review.content).font(.subheadline).foregroundStyle(.primary)
                                Text(formatDate(review.createdAt)).font(.caption).foregroundStyle(.gray)
                            }
                            Spacer()
                            StarRatingView(rating: review.rating)
                                .font(.caption).foregroundStyle(.gray)
                        }
                        .padding(.vertical, 10)
                        .listRowInsets(.init(top: 0, leading: 12, bottom: 0, trailing: 12))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
                .padding(.vertical)
                .padding(.trailing)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .navigationTitle("리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 8)
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        
        .navigationDestination(item: $selectedReview) { review in
            if let f = feed(forFeedId: review.feedId) {
                ReviewDetailView(feed: f, review: review)
            }
        }
    }
}
