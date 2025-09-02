//
//  StoreDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI
import FirebaseAuth

struct StoreProfileView: View {
    @StateObject private var storeVm = StoreVM()
    @StateObject private var ownVM = StoreOwnershipVM()
    @StateObject private var statsVM = StoreStatsVM()
    @StateObject private var subVM = SubscriptionVM()

    let storeId: String
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    @State private var selectedTab: StoreTab = .all
    private let grid = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
    @State private var isInfoExpanded = false
    @State private var route: Route? = nil
    @State private var isFollowed: Bool = true
    
    private func filteredFeeds(from feeds: [Feed]) -> [Feed] {
        switch selectedTab {
        case .all:     return feeds
        case .store:   return feeds.filter { $0.promoKind == .store }
        case .product: return feeds.filter { $0.promoKind == .product }
        case .event:   return feeds.filter { $0.promoKind == .event }
        }
    }
    @State private var selectedFeed: Feed? = nil
    
    
    var body: some View {
        ScrollView {
            if storeVm.isLoading {
                ProgressView("불러오는 중…").padding(.top, 24)
            } else if let err = storeVm.errorMessage {
                VStack(spacing: 8) {
                    Text("불러오기 실패").font(.headline)
                    Text(err).foregroundColor(.secondary).font(.caption)
                    Button("다시 시도") { Task { await storeVm.load(storeId: storeId) } }
                }
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack {
                            HStack(alignment: .center, spacing: 16) {
                                AsyncImage(url: URL(string: storeVm.profileImageURL ?? "")) { phase in
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
                                            Text("\(subVM.subscriptionCount)")
                                                .font(.subheadline).bold()
                                            Text("구독")
                                                .font(.subheadline).foregroundColor(.secondary)
                                        }
                                        VStack(spacing: 4) {
                                            if statsVM.isLoading {
                                                Text("…").font(.subheadline).bold()
                                            } else {
                                                Text("\(statsVM.totalLikes)")
                                                    .font(.subheadline).bold()
                                            }
                                            Text("좋아요")
                                                .font(.subheadline).foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    if ownVM.isOwner == true {
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
                                        Button {
                                            Task {
                                                if let uid = appUser?.id ?? Auth.auth().currentUser?.uid {
                                                    await subVM.toggle(storeId: storeId, userId: uid)
                                                }
                                            }
                                        } label: {
                                            Text(subVM.isSubscribe ? "구독중" : "구독")
                                                .font(.callout).bold()
                                                .foregroundColor(subVM.isSubscribe ? Color("Main") : .white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(subVM.isSubscribe ? .white : Color("Main"))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .stroke(Color("Main"), lineWidth: 1.2)
                                                )
                                        }
                                        .disabled(subVM.isBusy)
                                        .buttonStyle(.plain)
                                        
                                    }
                                    
                                }
                                .padding(.vertical)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("점포 소개")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.primary)
                                if let storeDescript = storeVm.storeDescript {
                                    Text(storeDescript)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                Divider()
                                    .background(Color.secondary.opacity(0.15))
                                    .padding(.vertical, 1)
                                
                                if isInfoExpanded {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                                            Text("점포 위치")
                                                .font(.subheadline).bold().foregroundColor(.primary)
                                            if let address = storeVm.address {
                                                Text(address).font(.subheadline).foregroundColor(.secondary)
                                            } else {
                                                Text("정보없음")
                                            }
                                        }
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                                            Text("전화번호")
                                                .font(.subheadline).bold().foregroundColor(.primary)
                                            if let phoneNumber = storeVm.phoneNumber {
                                                Text(phoneNumber).font(.subheadline).foregroundColor(.secondary)
                                            } else {
                                                Text("정보없음")
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                Text("평일 운영 시간")
                                                    .font(.subheadline).bold().foregroundColor(.primary)
                                                if let weekdayStart = storeVm.weekdayStart, let weekdayEnd = storeVm.weekdayEnd {
                                                    Text("\(weekdayStart) ~ \(weekdayEnd)")
                                                        .font(.subheadline).foregroundColor(.secondary)
                                                } else {
                                                    Text("정보없음")
                                                }
                                                
                                            }
                                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                Text("주말 운영 시간")
                                                    .font(.subheadline).bold().foregroundColor(.primary)
                                                if let weekendStart = storeVm.weekendStart, let weekendEnd = storeVm.weekendEnd {
                                                    Text("\(weekendStart) ~ \(weekendEnd)")
                                                        .font(.subheadline).foregroundColor(.secondary)
                                                } else {
                                                    Text("정보없음")
                                                }
                                            }
                                        }
                                    }
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
                                ForEach(filteredFeeds(from: storeVm.feeds)) { feed in
                                    SmallFeedCardView(feed: feed, selectedFeed: $selectedFeed, appUser: appUser)
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
        .navigationTitle("\(storeVm.storeName)")
        .navigationBarTitleDisplayMode(.inline)
        
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        .task(id: storeId) {
            await ownVM.refresh(storeId: storeId, userDocId: appUser?.id)
            await storeVm.load(storeId: storeId)
            await statsVM.refresh(storeId: storeId)
            await subVM.start(storeId: storeId, userId: appUser?.id ?? Auth.auth().currentUser?.uid)

        }
//        .task { await vm.fetch(storeId: storeId, userId: currentUserID) }
                .navigationDestination(item: $selectedFeed) { feed in
                    FeedView(feedId: feed.id.uuidString, appUser: appUser, storeId: storeId, selectedMarketID: $selectedMarketID)
        
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
    let feed: Feed
    @Binding var selectedFeed: Feed?
    @StateObject private var likeVM = FeedLikeVM()
    let appUser: AppUser?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button { selectedFeed = feed } label: {
                AsyncImage(url: feed.mediaUrl) { image in
                    image.resizable().scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15))
                        .frame(width: 110, height: 110)
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: likeVM.isLiked ? "heart.fill" : "heart").font(.footnote)
                    .foregroundColor(likeVM.isLiked ? Color("Main") :.primary)
                Text("\(likeVM.likesCount)")
                    .font(.footnote).foregroundColor(.primary)
                Spacer()
                Text(feed.title)
                    .font(.footnote).bold()
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }
        }
        .task {
            if let uid = appUser?.id {
                await likeVM.start(feedId: feed.id.uuidString, userId: uid)
            }
        }
        .onDisappear { likeVM.stop() }
    }
}


