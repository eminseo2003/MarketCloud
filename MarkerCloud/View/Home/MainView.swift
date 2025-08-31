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
    //@StateObject private var feedVM = FeedViewModel()
    @StateObject private var marketVm = MarketListVM()
    
    @State private var route: Route? = nil
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    @State private var selectedTab: StoreTab = .all
    @State private var pushStoreName: String? = nil
    @State private var pushStore: Int? = nil
    let columns = [
        GridItem(.flexible())
    ]
    private var selectedMarketTitle: String {
        marketVm.markets.first(where: { $0.id == selectedMarketID })?.marketName ?? "시장 선택"
    }
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
                        Picker("시장 선택", selection: $selectedMarketID) {
                            ForEach(marketVm.markets, id: \.id) { market in
                                        Text(market.marketName).tag(market.id)
                                    }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(
                                marketVm.markets.first(
                                    where: {
                                        $0.id == selectedMarketID
                                    }
                                )?.marketName
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
                    
//                    if feedVM.isLoading {
//                        ProgressView("불러오는 중…")
//                    } else if let err = feedVM.errorMessage {
//                        VStack(spacing: 8) {
//                            Text("불러오기 실패").font(.headline)
//                            Text(err).foregroundColor(.secondary).font(.caption)
////                            Button("다시 시도") {
////                                Task {
////                                    await feedVM.fetch(marketId: selectedMarketID, appUser: appUser)
////                                }
////                            }
//                        }
//                        .padding(.vertical, 24)
//                    } else {
//                        let insertAfter = 1
//                        LazyVStack(spacing: 12) {
//                            let indices = filteredFeedIndices
//                            ForEach(Array(indices.enumerated()), id: \.element) { (pos, i) in
//                                //FeedCardView(feed: $feedVM.feeds[i], pushStoreName: $pushStoreName, appUser: appUser, pushStore: $pushStore)
//                                
//                                if pos == insertAfter {
//                                    Button(action: {
//                                        route = .todayMarket
//                                    }) {
//                                        MainRowButton(title: "오늘의 시장 추천받기",
//                                                  value: "🍀",
//                                                  icon: "chevron.right")
//                                        .padding(16)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
//                                                .fill(Color(uiColor: .systemGray6))
//                                        )
//                                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
//                                        .padding(.horizontal, 16)
//                                        .padding(.vertical, 16)
//                                    }
//                                    
//                                }
//                            }
//                        }
//                    }
                }
                .onAppear { marketVm.load() }
//                .task {
//                    await feedVM.fetch(marketId: selectedMarketID, appUser: appUser)
//                    await marketVm.fetch()
//                }
//                .refreshable {
//                    await feedVM.fetch(marketId: selectedMarketID, appUser: appUser)
//                }
//                .onChange(of: selectedMarketID) { oldValue, newValue in
//                    Task {
//                        await feedVM.fetch(marketId: selectedMarketID, appUser: appUser)
//                    }
//                }
                Spacer()
                
            }
            //            .navigationDestination(item: $pushStore) { store in
            //                StoreProfileView(store: store)
            //            }
            .navigationDestination(item: $route) { route in
                if route == .todayMarket {
                    //SelectKeywordView(selectedMarketID: $selectedMarketID)
                }
            }
            .navigationDestination(item: $pushStore) { id in
                if let storeId = pushStore {
                    //StoreProfileView(storeId: id, currentUserID: currentUserID)
                } else {
                    Text("잘못된 점포입니다.")
                }
            }
        }
        
    }
//    private var filteredFeedIndices: [Int] {
//        feedVM.feeds.indices.filter { i in
//            let f = feedVM.feeds[i]
//            switch selectedTab {
//            case .all:     return true
//            case .store:   return f.feedType == "store"   || f.feedType == "점포"
//            case .product: return f.feedType == "product" || f.feedType == "상품"
//            case .event:   return f.feedType == "event"   || f.feedType == "이벤트"
//            }
//        }
//    }
}

struct MainRowButton: View {
    let title: String
    let value: String
    let icon: String?
    private let iconWidth: CGFloat = 12
    
    var body: some View {
        HStack {
            Text(title).font(.body).bold().foregroundColor(.primary)
            Spacer(minLength: 12)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(1)
            if let icon {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .frame(width: iconWidth, alignment: .trailing)
            } else {
                Color.clear.frame(width: iconWidth)
            }
            
        }
        .frame(minHeight: 46)
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }
}
