//
//  ProductDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct FeedView: View {
    let feedId: String
    let appUser: AppUser?
    let storeId: String
    @Binding var selectedMarketID: Int

    @StateObject private var vm = FeedVM()
    @StateObject private var storeVm = StoreHeaderVM()
    @StateObject private var likeVM = FeedLikeVM()
    @StateObject private var reviewVM = ReviewListVM()
    @State private var isCommentSheetPresented = false
    @State private var pushFeedId: String? = nil
    @State private var pushStoreId: String? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                if vm.isLoading {
                    VStack(spacing: 12) {
                        ProgressView("불러오는 중…")
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                } else if let err = vm.errorMessage {
                    VStack(spacing: 8) {
                        Text("불러오기 실패").font(.headline)
                        Text(err).font(.caption).foregroundStyle(.secondary)
                        Button("다시 시도") {
                            Task { await vm.load(feedId: feedId) }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            pushStoreId = vm.storeId
                        } label: {
                            HStack {
                                StoreAvatarView(url: URL(string: storeVm.profileURL ?? ""), size: 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(storeVm.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(formatDate(from: vm.createdAt ?? Date()))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }.padding(.horizontal)
                        
                        AsyncImage(url: URL(string: vm.mediaUrl ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Button {
                                    Task { await likeVM.toggle() }
                                } label: {
                                    Image(systemName: likeVM.isLiked ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundColor(likeVM.isLiked ? Color("Main") :.primary)
                                }
                                Text("\(likeVM.likesCount)")
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                            
                            HStack(spacing: 4) {
                                Button {
                                    isCommentSheetPresented = true
                                } label: {
                                    Image(systemName: "bubble")
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                }
                                Text("\(reviewVM.reviewsCount)")
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        (
                            Text(vm.title ?? "").bold() +
                            Text(vm.body ?? "")
                        )
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                    }
                    .padding(.top, 10)
                    
                }
            }
            Button(action: {
                pushFeedId = feedId
            }) {
                Text("피드 상세보기")
            }.buttonStyle(FilledCTA())
                .padding()
        }
        .navigationTitle(vm.title ?? "제목 없음")
        .navigationDestination(item: $pushStoreId) { storeId in
            StoreProfileView(storeId: storeId, appUser: appUser, selectedMarketID: $selectedMarketID)
        }
        .navigationDestination(item: $pushFeedId) { feedId in
            FeedDetailView(feedId: feedId, appUser: appUser, selectedMarketID: $selectedMarketID)
        }
        .task {
            await vm.load(feedId: feedId)
            await storeVm.load(storeId: storeId)
            await reviewVM.load(feedId: feedId)
            if let uid = appUser?.id {
                await likeVM.start(feedId: feedId, userId: uid)
            }
        }
        .onDisappear { likeVM.stop() }
        .sheet(isPresented: $isCommentSheetPresented, onDismiss: {
            Task {
                await storeVm.load(storeId: storeId)
                await reviewVM.load(feedId: feedId)
            }
        }) {
            CommentSheetView(feedId: feedId, appUser: appUser)
                .presentationDetents([.medium])
        }
    }
}
