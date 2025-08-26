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
    var imageFeeds: [Feed] { dummyFeed.filter { $0.mediaType == .image } }
    private func feeds(for store: Store) -> [Feed] {
        let storeFeeds = imageFeeds.filter { $0.storeId == store.id }
        
        switch selectedTab {
        case .all:
            return storeFeeds
        case .store:
            return storeFeeds.filter { $0.promoKind == .store }
        case .product:
            return storeFeeds.filter { $0.promoKind == .product }
        case .event:
            return storeFeeds.filter { $0.promoKind == .event }
        }
    }
    
    
    @Binding var selectedMarketID: String
    
    @State private var selectedTab: StoreTab = .all
    private var selectedMarketUUID: UUID? {
        UUID(uuidString: selectedMarketID)
    }
    private var storesInSelectedMarket: [Store] {
        guard let id = selectedMarketUUID else { return [] }
        return dummyStores.filter { $0.marketId == id }
    }
    @State private var pushStore: Store? = nil
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
                        ForEach(dummyMarkets) { market in
                            Button(market.marketName) {
                                selectedMarketID = market.id.uuidString
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text({
                                if let id = selectedMarketUUID,
                                   let m = dummyMarkets.first(where: { $0.id == id }) {
                                    return m.marketName
                                } else {
                                    return "시장 선택"
                                }
                            }())
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
                    LazyVGrid(columns: columns, spacing: 8) {
                        VStack(spacing: 16) {
                            ForEach(storesInSelectedMarket) { store in
                                ForEach(feeds(for: store)) { feed in
                                    FeedCardView(feed: feed, store: store, pushStore: $pushStore)
                                }
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                    
                }
                .refreshable {
                    
                }
                Spacer()
                
            }
            .navigationDestination(item: $pushStore) { store in
                StoreProfileView(store: store)
            }
        }
        
    }
    
}

