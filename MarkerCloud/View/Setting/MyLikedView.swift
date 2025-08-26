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
    let feedList: [Feed]
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    private var filteredFeeds: [Feed] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return feedList }
        let nq = q.normalizedForSearch
        
        return feedList.filter { p in
            p.body.normalizedForSearch.contains(nq) ||
            p.body.normalizedForSearch.contains(nq)
        }
    }
    @State private var selectedFeed: Feed? = nil
    var body: some View {
        if feedList.isEmpty {
            HStack {
                Spacer()
                Text("좋아요한 게시물이 없습니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle(Text("좋아요"))
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
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("완료") { hideKeyboard() }
                    }
                }
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
                                ProductCard(product: feed, selectedProduct: $selectedFeed)
                            }
                        }
                        .padding(.horizontal)
                        .animation(.snappy, value: filteredFeeds.count)
                    }
                    
                }
            }
            .navigationDestination(item: $selectedFeed) { feed in
                FeedView(feed: feed)
                    //.navigationTitle(feed.eventName)
            }
            .navigationTitle("좋아요")
        }
        
    }
    private func hideKeyboard() {
        isTextFieldFocused = false
    }
}
