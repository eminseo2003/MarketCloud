//
//  MyLikedView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

private extension String {
    var normalizedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
struct MyLikedView: View {
    @StateObject private var vm = LikedFeedsVM()
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @State private var selectedFeed: FeedLite? = nil
    
    private var filteredFeeds: [FeedLite] {
        let src = vm.feeds
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return src }
        let nq = q.normalizedForSearch
        return src.filter { $0.body.normalizedForSearch.contains(nq) }
    }
    var body: some View {
        Group {
            if vm.isLoading && vm.feeds.isEmpty {
                ProgressView("불러오는 중…")
            } else if vm.feeds.isEmpty {
                HStack {
                    Spacer()
                    Text("좋아요한 게시물이 없습니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .navigationTitle("좋아요")
            } else {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("Main"))
                            .bold(true)
                        TextField("검색어를 입력하세요", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isTextFieldFocused)
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                isTextFieldFocused = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    ScrollView {
                        if filteredFeeds.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("검색 결과가 없어요")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                                ForEach(filteredFeeds) { feed in
                                    FeedCard(feed: feed, appUser: appUser, selectedMarketID: $selectedMarketID, selectedFeed: $selectedFeed)
                                }
                            }
                            .padding(.horizontal)
                            .animation(.snappy, value: filteredFeeds.count)
                        }
                        
                    }
                }
                .navigationTitle("좋아요")
                .navigationDestination(item: $selectedFeed) { feed in
                    FeedView(feedId: feed.id, appUser: appUser, storeId: feed.storeId, selectedMarketID: $selectedMarketID)
                }
                .refreshable {
                    if let uid = appUser?.id ?? appUser?.id {
                        vm.start(userId: uid)
                    }
                }
                
            }
        }.task {
            if vm.feeds.isEmpty, let uid = appUser?.id ?? appUser?.id{
                vm.start(userId: uid)
            }
        }
        .onDisappear { vm.stop() }
    
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("완료") { hideKeyboard() }
            }
        }
    }
    private func hideKeyboard() {
        isTextFieldFocused = false
    }
}
