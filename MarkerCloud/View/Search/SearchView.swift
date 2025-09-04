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
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var route: Route? = nil
    @StateObject private var storeRankVM = StoreRankVM()
    @StateObject private var productRankVM = ProductRankVM()
    @StateObject private var eventRankVM  = EventRankVM()
    @StateObject private var searchRankVM  = SearchRankVM()
    
    @State private var pushStoreId: String? = nil
    @State private var selectedFeedId: String? = nil
    @State private var selectedStoreId: String? = nil
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
                                retry: { Task { await storeRankVM.loadTopStores(marketId: selectedMarketID, limit: 10) } }
                            ) {
                                LazyHStack(spacing: 10) {
                                    ForEach(storeRankVM.stores) { s in
                                        StoreBubbleView(name: s.name, url: s.profileURL)
                                            .onTapGesture {
                                                pushStoreId = s.id
                                                print("tapped store:", s.name)
                                                route = .storeDetail
                                                
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            SearchViewSectionHeader(title: "인기 상품")
                            RankSectionHorizontal(
                                isLoading: productRankVM.isLoading,
                                error: productRankVM.errorMessage,
                                retry: { Task { await productRankVM.loadTopProducts(marketId: selectedMarketID, candidateLimit: 100, topN: 10) } }
                            ) {
                                LazyHStack(spacing: 12) {
                                    ForEach(productRankVM.products) { p in
                                        Button(action: {
                                            print("tapped product:", p.title)
                                            selectedFeedId = p.id
                                            selectedStoreId = p.storeId
                                            print("selectedFeedId: \(selectedFeedId ?? "")")
                                            print("selectedStoreId: \(selectedStoreId ?? "")")
                                            route = .feedDetail
                                        }) {
                                            MediaThumbCard(title: p.title, url: p.mediaURL, likeCount: p.likeCount,feedId: p.id, appUser: appUser)
                                                .foregroundColor(.primary)
                                            
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            SearchViewSectionHeader(title: "인기 이벤트")
                            RankSectionHorizontal(
                                isLoading: eventRankVM.isLoading,
                                error: eventRankVM.errorMessage,
                                retry: { Task { await eventRankVM.loadTopEvents(marketId: selectedMarketID, candidateLimit: 100, topN: 10) } }
                            ) {
                                LazyHStack(spacing: 12) {
                                    ForEach(eventRankVM.events) { e in
                                        Button(action: {
                                            print("tapped product:", e.title)
                                            selectedFeedId = e.id
                                            selectedStoreId = e.storeId
                                            print("selectedFeedId: \(selectedFeedId ?? "")")
                                            print("selectedStoreId: \(selectedStoreId ?? "")")
                                            route = .feedDetail
                                        }) {
                                            MediaThumbCard(title: e.title, url: e.mediaURL, likeCount: e.likeCount,feedId: e.id, appUser: appUser)
                                                .foregroundColor(.primary)
                                            
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                } else {
                    ScrollView {
                        VStack {
                            TrendingKeywordsView(keywords: searchRankVM.rankings, searchText: $searchText, route: $route)
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        Task {
                                await searchRankVM.bumpAndRefresh(keyword: searchText)
                                route = .searchResult
                            }
                    }) {
                        Text("검색")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Main"))
                    }
                    
                }
            }
            .task {
                await storeRankVM.loadTopStores(marketId: selectedMarketID, limit: 10)
                await productRankVM.loadTopProducts(marketId: selectedMarketID, candidateLimit: 100, topN: 10)
                await eventRankVM.loadTopEvents(marketId: selectedMarketID, candidateLimit: 100, topN: 10)
                await searchRankVM.fetchTop5()
            }
            .onChange(of: searchText) { _, new in
                if new.isEmpty {
                    Task { await searchRankVM.fetchTop5() }
                }
            }

            .navigationDestination(item: $route) { route in
                if route == .storeDetail {
                    if let storeId = pushStoreId {
                        StoreProfileView(storeId: storeId, appUser: appUser, selectedMarketID: $selectedMarketID)
                    }
                } else if route == .searchResult {
                    SearchResultView(keyword: searchText, appUser: appUser, selectedMarketID: $selectedMarketID)
                }
            }
            .navigationDestination(item: $selectedFeedId) { feedId in
                if let storeId = selectedStoreId {
                    FeedView(feedId: feedId, appUser: appUser, storeId: storeId, selectedMarketID: $selectedMarketID)
                    
                }
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

struct StoreBubbleView: View {
    let name: String
    let url: URL?
    
    var body: some View {
        VStack {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Circle().fill(Color(.systemGray5))
                            ProgressView()
                        }.frame(width: 56, height: 56)
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
            } else {
                Circle().fill(Color(.systemGray5))
                    .overlay(Image(systemName: "photo"))
                    .frame(width: 56, height: 56)
            }
            Text(name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}
struct MediaThumbCard: View {
    @StateObject private var likeVM = FeedLikeVM()
    let title: String
    let url: URL?
    let likeCount: Int
    let feedId: String
    let appUser: AppUser?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: url, transaction: .init(animation: .default)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color(.systemGray6))
                        ProgressView()
                    }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(let error):
                    ZStack {
                        Rectangle().fill(Color(.systemGray6))
                        VStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle").imageScale(.large)
                            Text("이미지 로드 실패")
                                .font(.caption2)
                            if let u = url {
                                // 디버그: 실제 URL 찍어보기
                                Text(u.absoluteString)
                                    .font(.caption2)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onAppear {
                        print("[MediaThumbCard] image load failed for:", url?.absoluteString ?? "nil",
                              "| error:", error.localizedDescription)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 160, height: 160)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                if let u = url { debugFetchImage(u) }
            }


            HStack {
                HStack(spacing: 4) {
                    Button {
                        Task { await likeVM.toggle() }
                    } label: {
                        Image(systemName: likeVM.isLiked ? "heart.fill" : "heart")
                            .font(.caption2)
                            .foregroundColor(likeVM.isLiked ? Color("Main") :.primary)
                    }
                    Text("\(likeCount)")
                        .font(.caption2)
                        .foregroundColor(.primary)
                        .bold()
                }
                Spacer()
                Text(title).font(.caption).lineLimit(1)
            }
            .frame(width: 160, alignment: .center)
        }
        .onAppear {
            print("[MediaThumbCard] url =", url?.absoluteString ?? "nil")
        }
        .task {
            if let uid = appUser?.id {
                await likeVM.start(feedId: feedId, userId: uid)
            }
        }
        .onDisappear { likeVM.stop() }
    }
}
private func debugFetchImage(_ url: URL) {
    Task {
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let http = resp as? HTTPURLResponse
            print("[IMG DEBUG] status=", http?.statusCode ?? -1,
                  "mime=", http?.mimeType ?? "nil",
                  "bytes=", data.count)
        } catch {
            print("[IMG DEBUG] error:", error.localizedDescription)
        }
    }
}

//struct MediaThumbCard: View {
//    let title: String
//    let url: URL?
//    let likeCount: Int?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .empty:
//                    ZStack {
//                        Rectangle().fill(Color(.systemGray6))
//                        ProgressView()
//                    }
//                case .success(let image):
//                    image.resizable().scaledToFill()
//                case .failure:
//                    ZStack {
//                        Rectangle().fill(Color(.systemGray6))
//                        Image(systemName: "photo").imageScale(.large)
//                    }
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            .frame(width: 160, height: 160)
//            .clipped()
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            
//            HStack {
//                if let like = likeCount {
//                    HStack(spacing: 4) {
//                        Image(systemName: "heart.fill").font(.caption2)
//                        Text("\(like)")
//                            .font(.caption2)
//                    }
//                    .foregroundColor(.secondary)
//                }
//                Spacer()
//                Text(title)
//                    .font(.caption)
//                    .lineLimit(1)
//                
//            }
//            .frame(width: 160, alignment: .center)
//            
//            
//        }
//    }
//}

private struct TrendingKeywordsView: View {
    let keywords: [String]
    @Binding var searchText: String
    @Binding var route: Route?
    
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
                    Button(action: {
                        self.searchText = keyword
                        route = .searchResult
                    }) {
                        HStack(spacing: 8) {
                            Text("\(idx + 1)")
                                .font(.subheadline).bold()
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle().fill(Color(uiColor: .secondarySystemBackground))
                                )
                                .foregroundColor(.primary)
                            
                            Text(keyword)
                                .font(.body).bold()
                                .lineLimit(1)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    
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
