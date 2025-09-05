//
//  MyReviewListView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct MyReviewListView: View {
    @StateObject private var vm = MyReviewsVM()
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    @State private var selectedReview: Review? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                
                if vm.isLoading && vm.reviews.isEmpty {
                    ProgressView("불러오는 중…")
                        .padding(.vertical, 40)
                } else if vm.reviews.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("작성한 리뷰가 없습니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 40)
                } else {
                    List(vm.reviews) { review in
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
                    .refreshable {
                        if let uid = appUser?.id ?? appUser?.id {
                            vm.start(userId: uid)
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .navigationTitle("리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 8)
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        
        .navigationDestination(item: $selectedReview) { review in
            ReviewDetailView(feedId: review.feedId, review: review, selectedMarketID: $selectedMarketID, appUser: appUser)
        }
        .task {
            if let uid = appUser?.id ?? appUser?.id { vm.start(userId: uid) }
        }
        .onDisappear { vm.stop() }
    }
    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }
}
