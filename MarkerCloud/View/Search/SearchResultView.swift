//
//  SearchResultView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/15/25.
//

import SwiftUI
import FirebaseAuth
//
//struct SearchResultView: View {
//    let keyword: String
//    @StateObject private var vm = SearchResultVM()
//    
//    let columns = [GridItem(.flexible()), GridItem(.flexible())]
//    @State private var route: Route? = nil
//    //    var filteredStores: [Store] {
//    //        return dummyStores.filter { (store: Store) -> Bool in
//    //            store.storeName.contains(keyword)
//    //        }
//    //    }
//    //    var filteredProducts: [Feed] {
//    //        dummyFeed
//    //            .filter { $0.promoKind == .product }
//    //            .filter { $0.title.localizedCaseInsensitiveContains(keyword)}
//    //    }
//    //
//    //    var filteredEvents: [Feed] {
//    //        dummyFeed
//    //            .filter { $0.promoKind == .event }
//    //            .filter { $0.title.localizedCaseInsensitiveContains(keyword)}
//    //    }
//    
//    //@State private var selectedStore: Store? = nil
//    @State private var selectedProduct: Feed? = nil
//    @State private var selectedEvent: Feed? = nil
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                
//                SectionHeader(title: "점포", route: $route)
//                if vm.isLoading {
//                    HStack { Spacer(); ProgressView(); Spacer() }
//                } else if let err = vm.errorMessage {
//                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
//                } else if vm.stores.isEmpty {
//                    HStack { Spacer(); Text("검색 결과가 없습니다.").font(.caption).foregroundColor(.secondary); Spacer() }
//                } else {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 12) {
//                            ForEach(vm.stores.prefix(10)) { s in
//                                VStack {
//                                    AsyncImage(url: s.imgURL) { img in
//                                        img
//                                            .resizable()
//                                            .scaledToFill()
//                                    } placeholder: {
//                                        ProgressView()
//                                    }
//                                        .frame(width: 56, height: 56)
//                                        .clipShape(Circle())
//                                    
//                                    Text(s.name).font(.caption2).lineLimit(1)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                }
////                if filteredStores.isEmpty {
////                    HStack {
////                        Spacer()
////                        Text("검색 결과가 없습니다.")
////                            .font(.caption)
////                            .foregroundColor(.secondary)
////                        Spacer()
////                    }
////                } else {
////                    ScrollView(.horizontal, showsIndicators: false) {
////                        HStack(spacing: 12) {
////                            ForEach(filteredStores.prefix(10)) { store in
////                                VStack {
////                                    Button {
////                                        selectedStore = store
////                                        route = .storeDetail
////                                    } label: {
////                                        AsyncImage(url: store.profileImageURL) { image in
////                                            image
////                                                .resizable()
////                                                .scaledToFill()
////                                                .frame(width: 56, height: 56)
////                                                .clipShape(Circle())
////                                                .background(Circle().fill(Color(.systemGray5)))
////                                        } placeholder: {
////                                            ProgressView()
////                                        }
////                                    }
////                                    
////                                    Text(store.storeName)
////                                        .font(.caption2)
////                                        .lineLimit(1)
////                                }
////                            }
////                        }
////                        .padding(.horizontal)
////                    }
////                }
//                
//                
//                SectionHeader(title: "상품", route: $route)
//                if vm.isLoading {
//                    HStack { Spacer(); ProgressView(); Spacer() }
//                } else if let err = vm.errorMessage {
//                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
//                } else if vm.products.isEmpty {
//                    HStack { Spacer(); Text("검색 결과가 없습니다.").font(.caption).foregroundColor(.secondary); Spacer() }
//                } else {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack(spacing: 12) {
//                                            ForEach(vm.products.prefix(10)) { p in
//                                                MediaThumbCard(title: p.name, url: p.mediaURL, likeCount: p.likeCount)
//                                            }
//                                        }.padding(.horizontal)
//                                    }
//                }
//                
////                if !filteredProducts.isEmpty {
////                    ScrollView(.horizontal, showsIndicators: false) {
////                        HStack(spacing: 12) {
////                            ForEach(filteredProducts.prefix(10)) { product in
////                                FeedCard(feed: product, selectedFeed: $selectedProduct)
////                            }
////                        }
////                        
////                        .padding(.horizontal)
////                    }
////                } else {
////                    HStack {
////                        Spacer()
////                        Text("검색 결과가 없습니다.")
////                            .font(.caption)
////                            .foregroundColor(.secondary)
////                        Spacer()
////                    }
////                }
//                
//                SectionHeader(title: "이벤트", route: $route)
//                if vm.isLoading {
//                    HStack { Spacer(); ProgressView(); Spacer() }
//                } else if let err = vm.errorMessage {
//                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
//                } else if vm.events.isEmpty {
//                    HStack { Spacer(); Text("검색 결과가 없습니다.").font(.caption).foregroundColor(.secondary); Spacer() }
//                } else {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack(spacing: 12) {
//                                            ForEach(vm.events.prefix(10)) { e in
//                                                MediaThumbCard(title: e.name, url: e.mediaURL, likeCount: e.likeCount)
//                                            }
//                                        }.padding(.horizontal)
//                                    }
//                }
//                
////                if !filteredEvents.isEmpty {
////                    ScrollView(.horizontal, showsIndicators: false) {
////                        HStack(spacing: 12) {
////                            ForEach(filteredEvents.prefix(10)) { event in
////                                FeedCard(feed: event, selectedFeed: $selectedEvent)
////                            }
////                        }
////                        .padding(.horizontal)
////                        
////                    }
////                } else {
////                    HStack {
////                        Spacer()
////                        Text("검색 결과가 없습니다.")
////                            .font(.caption)
////                            .foregroundColor(.secondary)
////                        Spacer()
////                    }
////                    
////                }
//            }
//        }
//        .navigationTitle("검색 결과")
//        .task { await vm.fetch(keyword: keyword) }
//        .navigationDestination(item: $route) { route in
//            if route == .moreStore {
//                MoreStoreView(searchResultStore: vm.stores)
//            } else if route == .moreProduct {
//                MoreProductView(searchResultProduct: vm.products)
//            } else if route == .moreEvent {
//                MoreEventView(searchResultEvent: vm.events)
////            } else if route == .storeDetail {
////                if let store = selectedStore {
////                    StoreProfileView(store: store)
////                }
//            }
//        }
////        .navigationDestination(item: $selectedProduct) { product in
////            FeedView(feed: product)
////        }
////        .navigationDestination(item: $selectedEvent) { event in
////            FeedView(feed: event)
////        }
//        
//    }
//}
//
//struct SectionHeader: View {
//    let title: String
//    @Binding var route: Route?
//    
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.headline)
//            Spacer()
//            Button("더보기") {
//                switch title {
//                case "점포":
//                    route = .moreStore
//                case "상품":
//                    route = .moreProduct
//                case "이벤트":
//                    route = .moreEvent
//                default:
//                    break
//                }
//                
//            }
//            .font(.caption)
//            .foregroundColor(.gray)
//            
//        }
//        .padding(.horizontal)
//        .padding(.top)
//    }
//}
//
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

