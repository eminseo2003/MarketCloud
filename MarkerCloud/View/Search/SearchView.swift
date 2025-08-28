//
//  SearchView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/15/25.
//

import SwiftUI

struct Item: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageURL: URL
}
struct PopularSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [Item]
}
struct SearchView: View {
    @Binding var selectedMarketID: String
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var route: Route? = nil
    //    private var firstStore: Store? {
    //        dummyStores.first
    //    }
    //    private var productFeeds: [Feed] { dummyFeed.filter { $0.promoKind == .product } }
    //    private var eventFeeds: [Feed]   { dummyFeed.filter { $0.promoKind == .event } }
    @StateObject private var storeRankVM = StoreRankVM()
    @StateObject private var productRankVM = ProductRankVM()
    @StateObject private var eventRankVM  = EventRankVM()
    @StateObject private var searchRankVM  = SearchRankVM()
    
    @State private var pushStore: Store? = nil
    @State private var selectedFeed: Feed? = nil
    @State private var selectedSectionTitle: String? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image("screentoplogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text("Market Cloud")
                        .foregroundColor(.black)
                        .frame(height: 30)
                        .font(.title)
                        .bold(true)
                    Spacer()
                }
                .padding(.horizontal)
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
                
                if searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            
                            SearchViewSectionHeader(title: "인기 점포")
                            RankSectionHorizontal(
                                isLoading: storeRankVM.isLoading,
                                error: storeRankVM.errorMessage,
                                retry: { Task { await storeRankVM.fetch() } }
                            ) {
                                LazyHStack(spacing: 12) {
                                    ForEach(storeRankVM.stores) { s in
                                        StoreBubbleView(name: s.name, url: s.imageURL)
                                            .onTapGesture {
                                                // 점포 상세로 이동
                                                print("tapped store:", s.name)
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            //                            if dummyStores.isEmpty {
                            //                                HStack {
                            //                                    Spacer()
                            //                                    Text("점포가 없습니다.")
                            //                                        .font(.caption)
                            //                                        .foregroundColor(.secondary)
                            //                                    Spacer()
                            //                                }
                            //                            } else {
                            //                                ScrollView(.horizontal, showsIndicators: false) {
                            //                                    HStack(spacing: 12) {
                            //                                        ForEach(dummyStores.prefix(10)) { store in
                            //                                            VStack {
                            //                                                Button {
                            //                                                    pushStore = store
                            //                                                } label: {
                            //                                                    AsyncImage(url: store.profileImageURL) { image in
                            //                                                        image
                            //                                                            .resizable()
                            //                                                            .scaledToFill()
                            //                                                            .frame(width: 56, height: 56)
                            //                                                            .clipShape(Circle())
                            //                                                            .background(Circle().fill(Color(.systemGray5)))
                            //                                                    } placeholder: {
                            //                                                        ProgressView()
                            //                                                    }
                            //                                                }
                            //
                            //                                                Text(store.storeName)
                            //                                                    .font(.caption2)
                            //                                                    .lineLimit(1)
                            //                                            }
                            //                                        }
                            //                                    }
                            //                                    .padding(.horizontal)
                            //                                }
                            //                            }
                            
                            
                            SearchViewSectionHeader(title: "인기 상품")
                            RankSectionHorizontal(
                                isLoading: productRankVM.isLoading,
                                error: productRankVM.errorMessage,
                                retry: { Task { await productRankVM.fetch() } }
                            ) {
                                LazyHStack(spacing: 12) {
                                    ForEach(productRankVM.products) { p in
                                        MediaThumbCard(title: p.name, url: p.imageURL, likeCount: p.likeCount)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            //                            if !productFeeds.isEmpty {
                            //                                ScrollView(.horizontal, showsIndicators: false) {
                            //                                    HStack(spacing: 12) {
                            //                                        ForEach(productFeeds.prefix(10)) { feed in
                            //                                            FeedCard(feed: feed, selectedFeed: $selectedFeed)
                            //                                        }
                            //                                    }
                            //
                            //                                    .padding(.horizontal)
                            //                                }
                            //
                            //                            } else {
                            //                                HStack {
                            //                                    Spacer()
                            //                                    Text("상품이 없습니다.")
                            //                                        .font(.caption)
                            //                                        .foregroundColor(.secondary)
                            //                                    Spacer()
                            //                                }
                            //                            }
                            
                            SearchViewSectionHeader(title: "인기 이벤트")
                            RankSectionHorizontal(
                                isLoading: eventRankVM.isLoading,
                                error: eventRankVM.errorMessage,
                                retry: { Task { await eventRankVM.fetch() } }
                            ) {
                                LazyHStack(spacing: 12) {
                                    ForEach(eventRankVM.events) { e in
                                        MediaThumbCard(title: e.name, url: e.imageURL, likeCount: e.likeCount)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            //                            if !eventFeeds.isEmpty {
                            //                                ScrollView(.horizontal, showsIndicators: false) {
                            //                                    HStack(spacing: 12) {
                            //                                        ForEach(eventFeeds.prefix(10)) { feed in
                            //                                            FeedCard(feed: feed, selectedFeed: $selectedFeed)
                            //                                        }
                            //                                    }
                            //
                            //                                    .padding(.horizontal)
                            //                                }
                            //
                            //                            } else {
                            //                                HStack {
                            //                                    Spacer()
                            //                                    Text("이벤트가 없습니다.")
                            //                                        .font(.caption)
                            //                                        .foregroundColor(.secondary)
                            //                                    Spacer()
                            //                                }
                            //
                            //                            }
                        }
                    }
                    //점포 상세로 이동
                    //                    .navigationDestination(item: $selectedFeed) { feed in
                    //                        //FeedView(feed: feed)
                    //                    }
                    //                    .navigationDestination(item: $pushStore) { store in
                    //                        //StoreProfileView(store: store)
                    //                    }
                } else {
                    ScrollView {
                        VStack {
                            if searchRankVM.isLoading {
                                HStack { Spacer(); ProgressView(); Spacer() }
                                    .padding(.vertical, 8)
                            } else if let err = searchRankVM.errorMessage {
                                VStack(spacing: 8) {
                                    Text("인기 검색어 불러오기 실패").font(.subheadline).bold()
                                    Text(err).font(.caption).foregroundColor(.secondary)
                                    Button("다시 시도") { Task { await searchRankVM.fetch() } }
                                }
                                .padding(.horizontal)
                            } else {
                                TrendingKeywordsView(keywords: searchRankVM.keywords)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        route = .searchResult
                    }) {
                        Text("검색")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Main"))
                    }
                    .navigationDestination(item: $route) { route in
                        if route == .searchResult {
                            SearchResultView(keyword: searchText)
                        }
                    }
                }
            }
            .task {
                await storeRankVM.fetch()
                await productRankVM.fetch()
                await eventRankVM.fetch()
                await searchRankVM.fetch()
            }
        }
    }
}
private struct RankSectionHorizontal<Content: View>: View {
    let isLoading: Bool
    let error: String?
    let retry: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        if isLoading {
            HStack { Spacer(); ProgressView(); Spacer() }
                .padding(.vertical, 8)
        } else if let err = error {
            VStack(spacing: 8) {
                Text("불러오기 실패").font(.subheadline).bold()
                Text(err).font(.caption).foregroundColor(.secondary)
                Button("다시 시도", action: retry)
            }
            .padding(.horizontal)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                content()
            }
        }
    }
}

private struct StoreBubbleView: View {
    let name: String
    let url: URL?
    
    var body: some View {
        VStack {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 56, height: 56)
                case .success(let image):
                    image.resizable().scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                case .failure:
                    Circle().fill(Color(.systemGray5))
                        .overlay(Image(systemName: "photo").imageScale(.small))
                        .frame(width: 56, height: 56)
                @unknown default:
                    EmptyView()
                }
            }
            Text(name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

struct MediaThumbCard: View {
    let title: String
    let url: URL?
    let likeCount: Int?
    
    init(title: String, url: URL?, likeCount: Int? = nil) {
        self.title = title
        self.url = url
        self.likeCount = likeCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color(.systemGray6))
                        ProgressView()
                    }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    ZStack {
                        Rectangle().fill(Color(.systemGray6))
                        Image(systemName: "photo").imageScale(.large)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 140, height: 140)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 140, alignment: .leading)
            
            if let like = likeCount {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill").font(.caption2)
                    Text("\(like)")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
    }
}

private struct TrendingKeywordsView: View {
    let keywords: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .imageScale(.medium)
                Text("실시간 인기 검색어")
                    .font(.headline)
                Spacer()
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 4)
            .padding(.top, 10)
            
            VStack(spacing: 8) {
                ForEach(Array(keywords.enumerated()), id: \.offset) { idx, keyword in
                    HStack(spacing: 8) {
                        // 순위 뱃지
                        Text("\(idx + 1)")
                            .font(.subheadline).bold()
                            .frame(width: 28, height: 28)
                            .background(
                                Circle().fill(Color(uiColor: .secondarySystemBackground))
                            )
                        
                        Text(keyword)
                            .font(.body).bold()
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SearchViewSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
        }
        .padding(.horizontal)
        .padding(.top)
    }
}
