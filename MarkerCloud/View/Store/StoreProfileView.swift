//
//  StoreDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct StoreProfileView: View {
    let store: Store

    @State private var selectedTab: StoreTab = .all
    private let grid = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
    @State private var isInfoExpanded = false
    @State private var route: Route? = nil
    @State private var isMyStore: Bool = false
    @State private var isFollowed: Bool = true
    @State private var selectedFeed: Feed? = nil
    
    private func feeds(for store: Store) -> [Feed] {
        let storeFeeds = dummyFeed.filter { $0.storeId == store.id }
        
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 16) {
                        AsyncImage(url: store.profileImageURL) { phase in
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
                                    Text("4567")
                                        .font(.subheadline).bold()
                                    Text("구독")
                                        .font(.subheadline).foregroundColor(.secondary)
                                }
                                VStack(spacing: 4) {
                                    Text("45653")
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
                        if let desc = store.description, !desc.isEmpty {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }

                        
                    }
                    Divider().background(Color.secondary.opacity(0.15))

                    if isInfoExpanded {
                        extraStoreInfo
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
                .navigationDestination(item: $route) { route in
                    if route == .changeStoreInfo {
                        //ChangeStoreInfoView(store: store)
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Picker("필터 선택", selection: $selectedTab) {
                        ForEach(StoreTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    LazyVGrid(columns: grid, spacing: 12) {
                        ForEach(feeds(for: store)) { feed in
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
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        .navigationTitle(store.storeName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedFeed) { feed in
            if feed.promoKind == .product {
                FeedView(feed: feed)
            } else if feed.promoKind == .event {
                FeedView(feed: feed)
            }
            
        }
    }
    @ViewBuilder
    private var extraStoreInfo: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("점포 위치")
                    .font(.subheadline).bold().foregroundColor(.primary)
                if let road = store.address?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !road.isEmpty {
                    Text(road).font(.subheadline).foregroundColor(.secondary)
                }

            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("전화번호")
                    .font(.subheadline).bold().foregroundColor(.primary)
                if let tel = store.tel {
                    Text(tel).font(.subheadline).foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("평일 운영 시간")
                        .font(.subheadline).bold().foregroundColor(.primary)
                    Text("\(store.dayOpenTime.map { timeString(LocalTime(date: $0)) } ?? "-") ~ \(store.dayCloseTime.map { timeString(LocalTime(date: $0)) } ?? "-")")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("주말 운영 시간")
                        .font(.subheadline).bold().foregroundColor(.primary)
                    Text("\(store.weekendOpenTime.map { timeString(LocalTime(date: $0)) } ?? "-") ~ \(store.weekendCloseTime.map { timeString(LocalTime(date: $0)) } ?? "-")")
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
    let feed: Feed
    @Binding var selectedFeed: Feed?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                selectedFeed = feed
            } label: {
                RemoteThumb(url: feed.mediaUrl)
            }
            HStack(spacing: 6) {
                Image(systemName: "heart")
                    .font(.footnote)
                    .foregroundColor(.primary)
                Text("16")
                    .font(.footnote)
                    .foregroundColor(.primary)
                Spacer()
                Text(feed.title)
                    .font(.footnote).bold()
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }

            
        }
    }
}
