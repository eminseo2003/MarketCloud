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
    private var firstStore: Store? {
        dummyStores.first
    }
    private var storeFeeds: [Feed] { dummyStores.flatMap(\.feeds) }
    private var firstProducts: [Feed] { dummyFeed }
    private var firstEvents: [Feed] { dummyFeed }
    @State private var selectedStore: Store? = nil
    @State private var selectedStoreFeed: Feed? = nil
    @State private var selectedProductFeed: Feed? = nil
    @State private var selectedEventFeed: Feed? = nil
    
    
    @State private var selectedSectionTitle: String? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @StateObject private var keyboard = KeyboardResponder()
    
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
                            if dummyStores.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("점포가 없습니다.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(dummyStores.prefix(10)) { store in
                                            VStack {
                                                Button {
                                                    selectedStore = store
                                                    route = .storeDetail
                                                } label: {
                                                    AsyncImage(url: store.profileImageURL) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 56, height: 56)
                                                            .clipShape(Circle())
                                                            .background(Circle().fill(Color(.systemGray5)))
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                                
                                                Text(store.storeName)
                                                    .font(.caption2)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            
                            SearchViewSectionHeader(title: "인기 상품")
                            if !firstProducts.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(firstProducts.prefix(10)) { feed in
                                            ProductCard(product: feed, selectedProduct: $selectedProductFeed)
                                        }
                                    }
                                    
                                    .padding(.horizontal)
                                }
                                
                            } else {
                                HStack {
                                    Spacer()
                                    Text("상품이 없습니다.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            
                            SearchViewSectionHeader(title: "인기 이벤트")
                            if !firstEvents.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(firstEvents.prefix(10)) { feed in
                                            EventCard(event: feed, selectedEvent: $selectedEventFeed)
                                        }
                                    }
                                    
                                    .padding(.horizontal)
                                }
                                
                            } else {
                                HStack {
                                    Spacer()
                                    Text("이벤트가 없습니다.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                
                            }
                        }
                    }
                    .navigationDestination(item: $route) { route in
                        if route == .moreStore {
                            MoreStoreView(filteredStores: firstStore.map { [$0] } ?? [])
                        } else if route == .moreProduct {
                            MoreProductView(filteredProducts: firstProducts)
                        } else if route == .moreEvent {
                            MoreEventView(filteredEvents: firstEvents)
                        } else if route == .storeDetail {
                            if let store = selectedStore {
                                StoreProfileView(store: store)
                            }
                        }
                    }
                    .navigationDestination(item: $selectedProductFeed) { product in
                        ProductPostView(feed: product)
                    }
                    .navigationDestination(item: $selectedEventFeed) { event in
                        EventPostView(feed: event)
                    }
                } else {
                    ScrollView {
                        VStack() {
                            TrendingKeywordsView(
                                keywords: ["마라탕 맛집", "빵지순례", "핸드메이드 소품",
                                           "야시장 공연", "비 오는 날 카페"].prefix(5).map { String($0) }
                            )
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
