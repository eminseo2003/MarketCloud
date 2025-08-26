//
//  ReviewDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/19/25.
//

import SwiftUI

struct ProductReviewDetailView: View {
    let feed: Feed
    let review: Review
    @State private var selectedFeed: Feed? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button {
                    selectedFeed = feed
                } label: {
                    HStack(spacing: 12) {
                        AsyncImage(url: feed.mediaUrl) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Rectangle().fill(Color(uiColor: .systemGray5))
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Text(feed.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(uiColor: .white))
                    )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack {
                        if let imageName = review.imageURL {
                            LazyVGrid(columns: [GridItem()], spacing: 8) {
                                LargeReviewImage(url: imageName)
                            }
                        }
                        
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(review.content)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(formatDate(review.createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        StarRatingView(rating: review.rating)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(uiColor: .white))
                )
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        .navigationTitle("리뷰 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedFeed) { feed in
            ProductPostView(feed: feed)
                .navigationTitle(feed.title)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }
}
struct LargeReviewImage: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .clipped()
            case .failure(_):
                Image(systemName: "photo")
                    .resizable().scaledToFit().padding(24)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundStyle(.secondary)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            default:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
