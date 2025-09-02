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
    @StateObject private var vm = FeedVM()
    
    @State private var route: Route? = nil
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    @State private var selectedTab: StoreTab = .all
    @State private var pushStoreId: String? = nil
    @State private var pushFeedId: String? = nil
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
                        ForEach(marketVm.markets, id: \.id) { m in
                            Button(m.marketName) {
                                selectedMarketID = m.id
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(marketVm.markets.first(where: { $0.id == selectedMarketID })?.marketName ?? "시장 선택")
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
                        }
                        .padding(.vertical, 24)
                    } else {
                        let filtered = feedVM.feeds.filter { f in
                            switch selectedTab {
                            case .all:     return true
                            case .store:   return f.promoKind == "store"
                            case .product: return f.promoKind == "product"
                            case .event:   return f.promoKind == "event"
                            }
                        }
                        
                        let insertAfter = 1
                        LazyVStack(spacing: 12) {
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { pair in
                                let pos = pair.offset
                                let f   = pair.element
                                FeedCardView(
                                    feed: f,
                                    pushStoreId: $pushStoreId,
                                    pushFeedId: $pushFeedId,
                                    appUser: appUser,
                                    route: $route
                                )
                                
                                if pos == insertAfter {
                                    Button(action: {
                                        route = .todayMarket
                                    }) {
                                        MainRowButton(title: "오늘의 시장 추천받기",
                                                      value: "🍀",
                                                      icon: "chevron.right")
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .fill(Color(uiColor: .systemGray6))
                                        )
                                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    marketVm.load()
                }
                .task {
                    if let pushFeedId = pushFeedId {
                        await vm.load(feedId: pushFeedId)
                        
                    }
                    
                }
                .onChange(of: pushFeedId) { _, newValue in
                    guard let id = newValue else { return }
                    Task {
                        await vm.load(feedId: id)
                    }
                }
                .onAppear {
                    feedVM.start(marketId: selectedMarketID)
                }
                .onChange(of: selectedMarketID) { _, newValue in
                    feedVM.start(marketId: newValue)
                }
                Spacer()
                
            }
            .navigationDestination(item: $pushStoreId) { storeId in
                StoreProfileView(storeId: storeId, appUser: appUser, selectedMarketID: $selectedMarketID)
            }
            .navigationDestination(item: $pushFeedId) { feedId in
                FeedDetailView(feedId: feedId, appUser: appUser, selectedMarketID: $selectedMarketID)
            }
            .navigationDestination(item: $route) { route in
                if route == .todayMarket {
                    //SelectKeywordView(selectedMarketID: $selectedMarketID)
                }
            }
        }
        
    }
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
