//
//  EventReviewDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct EventReviewDetailView: View {
    let event: Feed
    let review: Review
    @State private var selectedEvent: Feed? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button {
                    selectedEvent = event
                } label: {
                    HStack(spacing: 12) {
                        AsyncImage(url: event.mediaUrl) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Rectangle().fill(Color(uiColor: .systemGray5))
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Text(event.title)
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
        .navigationDestination(item: $selectedEvent) { event in
            EventPostView(feed: event)
                .navigationTitle(event.title)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }
}
