//
//  ReviewDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/19/25.
//

import SwiftUI

struct ReviewDetailView: View {
    @StateObject private var feedVm = FeedVM()
    let feedId: String
    let review: Review
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    @State private var selectedFeedId: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if feedVm.isLoading {
                    ProgressView("불러오는 중…").padding(.top, 24)
                } else if let err = feedVm.errorMessage {
                    VStack(spacing: 8) {
                        Text("불러오기 실패").font(.headline)
                        Text(err).foregroundColor(.secondary).font(.caption)
                        Button("다시 시도") { Task { await feedVm.load(feedId: feedId) } }
                    }
                    .padding(.vertical, 24)
                } else {
                    Button {
                        selectedFeedId = feedId
                    } label: {
                        HStack(spacing: 12) {
                            if let url = feedVm.mediaUrl {
                                AsyncImage(url: URL(string: url)) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Rectangle().fill(Color(uiColor: .systemGray5))
                                    }
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                               
                            
                            
                            Text(feedVm.title ?? "")
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
                    
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack {
                        if let imageName = review.imageURL {
                            LazyVGrid(columns: [GridItem()], spacing: 8) {
                                LargeReviewImage(url: imageName.absoluteString)
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
        .navigationDestination(item: $selectedFeedId) { feedId in
            if let storeId = feedVm.storeId {
                FeedView(
                    feedId: feedId,
                    appUser: appUser,
                    storeId: storeId,
                    selectedMarketID: $selectedMarketID
                )
            }
        }
        .task {
            await feedVm.load(feedId: feedId)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }
}
struct LargeReviewImage: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .clipped()
            case .failure(_):
                Image(systemName: "photo")
                    .resizable().scaledToFit().padding(24)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            default:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
