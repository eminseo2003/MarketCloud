//
//  StoreDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct StoreProfileView: View {
    @StateObject private var vm = StoreProfileVM()
    let storeId: Int
    let storeName: String
    @State private var selectedTab: StoreTab = .all
    private let grid = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
    @State private var isInfoExpanded = false
    @State private var route: Route? = nil
    @State private var isMyStore: Bool = true
    @State private var isFollowed: Bool = true
    
    private func filteredFeeds(from feeds: [StoreFeedPreviewUI]) -> [StoreFeedPreviewUI] {
        switch selectedTab {
        case .all:     return feeds
        case .store:   return feeds.filter { $0.type == "store"   || $0.type == "점포" }
        case .product: return feeds.filter { $0.type == "product" || $0.type == "상품" }
        case .event:   return feeds.filter { $0.type == "event"   || $0.type == "이벤트" }
        }
    }
    @State private var selectedFeed: StoreFeedPreviewUI? = nil
    
    var body: some View {
        ScrollView {
            if vm.isLoading {
                ProgressView("불러오는 중…").padding(.top, 24)
            } else if let err = vm.errorMessage {
                VStack(spacing: 8) {
                    Text("불러오기 실패").font(.headline)
                    Text(err).foregroundColor(.secondary).font(.caption)
                    Button("다시 시도") { Task { await vm.fetch(storeId: storeId) } }
                }
                .padding(.vertical, 24)
            } else if let p = vm.profile {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            AsyncImage(url: p.imageURL) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Circle().fill(Color(uiColor: .systemGray5))
                                }
                            }
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 30) {
                                    VStack(spacing: 4) {
                                        Text("\(p.followerCount)")
                                            .font(.subheadline).bold()
                                        Text("구독")
                                            .font(.subheadline).foregroundColor(.secondary)
                                    }
                                    VStack(spacing: 4) {
                                        Text("\(p.totalLikedCount)")
                                            .font(.subheadline).bold()
                                        Text("좋아요")
                                            .font(.subheadline).foregroundColor(.secondary)
                                    }
                                }
                                
                                if isMyStore == true {
                                    Button {
                                        route = .changeStoreInfo
                                    } label: {
                                        Text("점포 편집")
                                            .font(.callout).bold()
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(RoundedRectangle(cornerRadius: 12).fill(Color("Main")))
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)
                                } else {
                                    if isFollowed {
                                        Button {
                                            isFollowed.toggle()
                                        } label: {
                                            Text("구독")
                                                .font(.callout).bold()
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(RoundedRectangle(cornerRadius: 12).fill(Color("Main")))
                                        }
                                        .buttonStyle(.plain)
                                        .frame(maxWidth: .infinity)
                                    } else {
                                        Button {
                                            isFollowed.toggle()
                                        } label: {
                                            Text("구독 취소")
                                                .font(.callout).bold()
                                                .foregroundColor(Color("Main"))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color("Main"), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                
                            }
                            .padding(.vertical)
                        }
                        
                        
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("점포 소개")
                                .font(.subheadline).bold()
                                .foregroundColor(.primary)
                            if !p.description.isEmpty {
                                Text(p.description)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                
                                
                            }
                            Divider().background(Color.secondary.opacity(0.15))
                            
                            if isInfoExpanded {
                                extraStoreInfo(p)
                                    .animation(.easeInOut, value: isInfoExpanded)
                                    .padding(.top, 4)
                                
                                infoToggleButton(title: "점포 정보 접기") {
                                    withAnimation(.easeInOut) {
                                        isInfoExpanded = false
                                    }
                                }
                            } else {
                                infoToggleButton(title: "점포 정보 더보기") {
                                    withAnimation(.easeInOut) { isInfoExpanded = true }
                                }
                            }
                            
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        //                        .navigationDestination(item: $route) { route in
                        //                            if route == .changeStoreInfo {
                        //                                ChangeStoreInfoView(store: store)
                        //                            }
                        //                        }
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("필터 선택", selection: $selectedTab) {
                                ForEach(StoreTab.allCases) { tab in
                                    Text(tab.rawValue).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                            LazyVGrid(columns: grid, spacing: 12) {
                                ForEach(filteredFeeds(from: p.feeds)) { feed in
                                    SmallFeedCardView(feed: feed, selectedFeed: $selectedFeed)
                                }
                            }
                            .padding(6)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
            }
        }
        
            .background(Color(uiColor: .systemGray6).ignoresSafeArea())
            .navigationTitle(storeName)
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.fetch(storeId: storeId) }
        //        .navigationDestination(item: $selectedFeed) { feed in
        //            if feed.promoKind == .product {
        //                FeedView(feed: feed)
        //            } else if feed.promoKind == .event {
        //                FeedView(feed: feed)
        //            }
        //
        //        }
    }
    @ViewBuilder
    private func extraStoreInfo(_ p: StoreProfileUI) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("점포 위치")
                    .font(.subheadline).bold().foregroundColor(.primary)
                Text(p.address).font(.subheadline).foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("전화번호")
                    .font(.subheadline).bold().foregroundColor(.primary)
                Text(p.phoneNumber).font(.subheadline).foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("평일 운영 시간")
                        .font(.subheadline).bold().foregroundColor(.primary)
                    Text("\(p.weekdayStart) ~ \(p.weekdayEnd)")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("주말 운영 시간")
                        .font(.subheadline).bold().foregroundColor(.primary)
                    Text("\(p.weekendStart) ~ \(p.weekendEnd)")
                        .font(.subheadline).foregroundColor(.secondary)
                }
            }
        }
    }
    
    
    @ViewBuilder
    private func infoToggleButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(uiColor: .systemGray6))
                )
        }
        .buttonStyle(.plain)
    }
    
    //24시간제 "09:00" 형태 (원하면 "h:mm a"로 바꿔 AM/PM 표기 가능)
    private func timeString(_ t: LocalTime, ampm: Bool = false) -> String {
        var comps = DateComponents()
        comps.hour = t.hour
        comps.minute = t.minute
        let date = Calendar.current.date(from: comps) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = ampm ? "h:mm a" : "HH:mm"   // "12:48PM" 원하면 ampm: true
        return f.string(from: date)
    }
}
private struct SmallFeedCardView: View {
    let feed: StoreFeedPreviewUI
    @Binding var selectedFeed: StoreFeedPreviewUI?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button { selectedFeed = feed } label: {
                if let u = feed.mediaURL {
                    AsyncImage(url: u) { image in
                        image.resizable().scaledToFill()
                            .frame(height: 110)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15))
                            .frame(height: 110)
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15))
                        .frame(height: 110)
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: "heart").font(.footnote).foregroundColor(.primary)
                Text("\(feed.likeCount)")
                    .font(.footnote).foregroundColor(.primary)
                Spacer()
                Text(feed.name)
                    .font(.footnote).bold()
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }
        }
    }
}


