//
//  SearchResultView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/15/25.
//

import SwiftUI
import FirebaseAuth

struct SearchResultView: View {
    let keyword: String
    let appUser: AppUser?
    @StateObject private var vm = SearchResultVM()
    @Binding var selectedMarketID: Int
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var route: Route? = nil
    
    @State private var pushStoreId: String? = nil
    @State private var selectedFeedId: String? = nil
    @State private var selectedStoreId: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                SectionHeader(title: "점포", route: $route)
                if vm.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                } else if let err = vm.errorMessage {
                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
                } else if vm.stores.isEmpty {
                    HStack { Spacer(); Text("검색 결과가 없습니다.").font(.caption).foregroundColor(.secondary); Spacer() }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.stores.prefix(10)) { s in
                                StoreBubbleView(name: s.name, url: s.imgURL)
                                    .onTapGesture {
                                        pushStoreId = s.id
                                        print("tapped store:", s.name)
                                        route = .storeDetail
                                        
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                
                SectionHeader(title: "상품", route: $route)
                if vm.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                } else if let err = vm.errorMessage {
                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
                } else if vm.products.isEmpty {
                    HStack { Spacer(); Text("검색 결과가 없습니다.").font(.caption).foregroundColor(.secondary); Spacer() }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.products.prefix(10)) { p in
                                Button(action: {
                                    print("tapped product:", p.name)
                                    selectedFeedId = p.id
                                    selectedStoreId = p.storeId
                                    print("selectedFeedId: \(selectedFeedId ?? "")")
                                    print("selectedStoreId: \(selectedStoreId ?? "")")
                                    route = .feedDetail
                                }) {
                                    MediaThumbCard(title: p.name, url: p.mediaURL, likeCount: p.likeCount,feedId: p.id, appUser: appUser)
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                        }.padding(.horizontal)
                    }
                }
                
                SectionHeader(title: "이벤트", route: $route)
                if vm.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                } else if let err = vm.errorMessage {
                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
                } else if vm.events.isEmpty {
                    HStack { Spacer(); Text("검색 결과가 없습니다.").font(.caption).foregroundColor(.secondary); Spacer() }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.events.prefix(10)) { e in
                                Button(action: {
                                    print("tapped product:", e.name)
                                    selectedFeedId = e.id
                                    selectedStoreId = e.storeId
                                    print("selectedFeedId: \(selectedFeedId ?? "")")
                                    print("selectedStoreId: \(selectedStoreId ?? "")")
                                    route = .feedDetail
                                }) {
                                    MediaThumbCard(title: e.name, url: e.mediaURL, likeCount: e.likeCount,feedId: e.id, appUser: appUser)
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                        }.padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("검색 결과")
        .task { await vm.fetch(keyword: keyword) }
        .navigationDestination(item: $route) { route in
            if route == .moreStore {
                MoreStoreView(searchResultStore: vm.stores, appUser: appUser, selectedMarketID: $selectedMarketID)
            } else if route == .moreProduct {
                MoreProductView(searchResultProduct: vm.products, appUser: appUser)
            } else if route == .moreEvent {
                MoreEventView(searchResultEvent: vm.events, appUser: appUser)
            } else if route == .storeDetail {
                if let storeId = pushStoreId {
                    StoreProfileView(storeId: storeId, appUser: appUser, selectedMarketID: $selectedMarketID)
                }
            }
        }
        .navigationDestination(item: $selectedFeedId) { feedId in
            if let storeId = selectedStoreId {
                FeedView(feedId: feedId, appUser: appUser, storeId: storeId, selectedMarketID: $selectedMarketID)
                
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    @Binding var route: Route?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Button("더보기") {
                switch title {
                case "점포":
                    route = .moreStore
                case "상품":
                    route = .moreProduct
                case "이벤트":
                    route = .moreEvent
                default:
                    break
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct FeedCard: View {
    let feed: FeedLite
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    @Binding var selectedFeed: FeedLite?
    @StateObject private var likeVM = FeedLikeVM()
    @StateObject private var vm = MyProductVM()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                selectedFeed = feed
            } label: {
                AsyncImage(url: feed.mediaUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .clipped()
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable().scaledToFit().padding(24)
                            .frame(width: 180, height: 180)
                            .foregroundStyle(.secondary)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    default:
                        ProgressView()
                            .frame(width: 180, height: 180)
                            .frame(maxWidth: .infinity)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            HStack {
                Image(systemName: likeVM.isLiked ? "heart.fill" : "heart")
                    .font(.caption)
                    .foregroundColor(likeVM.isLiked ? Color("Main") :.primary)
                Text("\(likeVM.likesCount)")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
                Text(feed.title)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .task {
            if let uid = appUser?.id {
                await likeVM.start(feedId: feed.id, userId: uid)
            }
        }
        .onDisappear { likeVM.stop() }
        .onAppear {
            guard let uid = appUser?.id ?? Auth.auth().currentUser?.uid else { return }
            // 시장별 필터를 쓰고 싶으면 marketId: selectedMarketID 전달
            vm.start(userId: uid, marketId: selectedMarketID, includeDrafts: false)
        }
        .onChange(of: selectedMarketID) { _, new in
            guard let uid = appUser?.id ?? Auth.auth().currentUser?.uid else { return }
            vm.start(userId: uid, marketId: new, includeDrafts: false)
        }
        .onDisappear {
            vm.stop()
        }
    }
    
}
