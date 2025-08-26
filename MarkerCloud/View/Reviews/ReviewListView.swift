//
//  ReviewListView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/19/25.
//

import SwiftUI

struct ReviewListView: View {
    let reviews: [Review]
    let feed: Feed
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
    @State private var selectedReview: Review? = nil
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(String(format: "평점 %.1f점", averageRating))
                    .foregroundColor(.secondary)
                StarRatingView(rating: averageRating)
                Spacer()
            }
            .padding()
            .font(.headline)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)

                List(reviews) { review in
                    Button {
                        selectedReview = review
                    } label: {
                        HStack(spacing: 10) {
                            if let imageName = review.imageURL {
                                ReviewImage(url: imageName)
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
            ProductReviewDetailView(feed: feed, review: review)
        }
    }
}
