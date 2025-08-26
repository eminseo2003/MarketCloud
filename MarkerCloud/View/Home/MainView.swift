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
    var imageFeeds: [Feed] {
        dummyFeed.filter { $0.mediaType == .image }
    }
    @State private var selectedStore: Store? = nil
    @Binding var selectedMarketID: String
    
    @State private var selectedTab: StoreTab = .all
    private var selectedMarketUUID: UUID? {
        UUID(uuidString: selectedMarketID)
    }
    private var storesInSelectedMarket: [Store] {
        guard let id = selectedMarketUUID else { return [] }
        return dummyStores.filter { $0.marketId == id }
    }
    let columns = [
        GridItem(.flexible())
    ]
    var body: some View {
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
                //여기 맨위에서 스크롤하면 새로고침하는 기능을 넣고싶어
                LazyVGrid(columns: columns, spacing: 8) {
                    VStack(spacing: 16) {
                        ForEach(storesInSelectedMarket) { store in
                            ForEach(imageFeeds) { feed in
                                ProductCardView(feed: feed, store: store)
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
    }
    
}

