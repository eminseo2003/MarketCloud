//
//  MainView.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/31/25.
//

import SwiftUI

enum StoreTab: String, CaseIterable, Identifiable {
    case all = "전체"
    case store = "점포"
    case product = "상품"
    case event = "이벤트"
    var id: String { rawValue }
}
struct MainView: View {
    @StateObject private var feedVM = FeedViewModel()
    @StateObject private var marketVm = MarketListVM()
    //var imageFeeds: [Feed] { dummyFeed.filter { $0.mediaType == .image } }
    
    
    @Binding var selectedMarketID: Int
    @Binding var currentUserID: Int
    
    @State private var selectedTab: StoreTab = .all
//    private var selectedMarketUUID: UUID? {
//        UUID(uuidString: selectedMarketID)
//    }
    //    private var storesInSelectedMarket: [Store] {
    //        guard let id = selectedMarketUUID else { return [] }
    //        return dummyStores.filter { $0.marketId == id }
    //    }
    @State private var pushStoreName: String? = nil
    let columns = [
        GridItem(.flexible())
    ]
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
                    Menu {
                        ForEach(marketVm.markets) { market in
                            Button(market.name) {
                                selectedMarketID = market.code
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(
                                marketVm.markets.first(where: { $0.code == selectedMarketID })?.name
                                ?? "시장 선택"
                            )
                            Image(systemName: "chevron.down")
                        }
                        .font(.caption)
                        .foregroundColor(.black)
                    }
                    
                }
                .padding(.horizontal)
                
                ScrollView(.vertical, showsIndicators: false) {
                    Picker("필터 선택", selection: $selectedTab) {
                        ForEach(StoreTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if feedVM.isLoading {
                        ProgressView("불러오는 중…")
                    } else if let err = feedVM.errorMessage {
                        VStack(spacing: 8) {
                            Text("불러오기 실패").font(.headline)
                            Text(err).foregroundColor(.secondary).font(.caption)
                            Button("다시 시도") {
                                Task {
                                    await feedVM.fetch(marketId: selectedMarketID, userId: currentUserID)
                                    //await feedVM.fetch(marketId: selectedMarketID)
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredFeeds) { feed in
                                FeedCardView(feed: feed, pushStoreName: $pushStoreName)
                            }
                        }
                        .padding(.horizontal)
                    }
                    //                    LazyVGrid(columns: columns, spacing: 8) {
                    //                        VStack(spacing: 16) {
                    //                            ForEach(storesInSelectedMarket) { store in
                    //                                ForEach(feeds(for: store)) { feed in
                    //                                    FeedCardView(feed: feed, store: store, pushStore: $pushStore)
                    //                                }
                    //                            }
                    //
                    //                        }
                    //                        .padding(.horizontal)
                    //                    }
                    
                }
                .task {
                    // 최초 로드 시 실행
                    await feedVM.fetch(marketId: selectedMarketID, userId: currentUserID)
                    //await feedVM.fetch(marketId: selectedMarketID)
                    await marketVm.fetch()
                }
                .refreshable {
                    await feedVM.fetch(marketId: selectedMarketID, userId: currentUserID)
                    //await feedVM.fetch(marketId: selectedMarketID)
                }
                .onChange(of: selectedMarketID) { oldValue, newValue in
                    Task {
                        await feedVM.fetch(marketId: selectedMarketID, userId: currentUserID)
                        //await feedVM.fetch(marketId: selectedMarketID)
                    }
                }
                Spacer()
                
            }
            //            .navigationDestination(item: $pushStore) { store in
            //                StoreProfileView(store: store)
            //            }
        }
        
    }
    private var filteredFeeds: [Feed] {
        switch selectedTab {
        case .all:
            return feedVM.feeds
        case .store:
            return feedVM.feeds.filter { $0.feedType == "점포" }
        case .product:
            return feedVM.feeds.filter { $0.feedType == "상품" }
        case .event:
            return feedVM.feeds.filter { $0.feedType == "이벤트" }
        }
    }
}

