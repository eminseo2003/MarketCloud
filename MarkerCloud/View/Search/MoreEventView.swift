//
//  MoreEventView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct MoreEventView: View {
    let searchResultEvent: [SearchResultFeed]
    @State private var route: Route? = nil
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    @State private var selectedFeedId: String? = nil
    @State private var selectedStoreId: String? = nil
    
    var body: some View {
        NavigationStack {
            if searchResultEvent.isEmpty {
                HStack {
                    Spacer()
                    Text("검색 결과가 없습니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .navigationTitle(Text("이벤트 더보기"))
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(searchResultEvent) { e in
                            NavigationLink(
                                destination: FeedView(
                                    feedId: e.id,
                                    appUser: appUser,
                                    storeId: e.storeId,
                                    selectedMarketID: $selectedMarketID
                                )
                            ) {
                                MoreMediaThumbCard(title: e.name, url: e.mediaURL, likeCount: e.likeCount,feedId: e.id, appUser: appUser)
                                    .foregroundColor(.primary)
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                }
    //            .navigationDestination(item: $selectedEvent) { event in
    //                FeedView(feed: event)
    //            }
                .navigationTitle(Text("이벤트 더보기"))
            }
            
        }
    }
}

struct MoreMediaThumbCard: View {
    @StateObject private var likeVM = FeedLikeVM()
    let title: String
    let url: URL?
    let likeCount: Int
    let feedId: String
    let appUser: AppUser?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: url, transaction: .init(animation: .default)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color(.systemGray6))
                        ProgressView()
                    }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(let error):
                    ZStack {
                        Rectangle().fill(Color(.systemGray6))
                        VStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle").imageScale(.large)
                            Text("이미지 로드 실패")
                                .font(.caption2)
                            if let u = url {
                                // 디버그: 실제 URL 찍어보기
                                Text(u.absoluteString)
                                    .font(.caption2)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onAppear {
                        print("[MediaThumbCard] image load failed for:", url?.absoluteString ?? "nil",
                              "| error:", error.localizedDescription)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 180, height: 180)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                if let u = url { debugFetchImage(u) }
            }


            HStack {
                HStack(spacing: 4) {
                    Button {
                        Task { await likeVM.toggle() }
                    } label: {
                        Image(systemName: likeVM.isLiked ? "heart.fill" : "heart")
                            .font(.caption2)
                            .foregroundColor(likeVM.isLiked ? Color("Main") :.primary)
                    }
                    Text("\(likeCount)")
                        .font(.caption2)
                        .foregroundColor(.primary)
                        .bold()
                }
                Spacer()
                Text(title).font(.caption).lineLimit(1)
            }
            .frame(width: 180, alignment: .center)
        }
        .onAppear {
            print("[MediaThumbCard] url =", url?.absoluteString ?? "nil")
        }
        .task {
            if let uid = appUser?.id {
                await likeVM.start(feedId: feedId, userId: uid)
            }
        }
        .onDisappear { likeVM.stop() }
    }
}
private func debugFetchImage(_ url: URL) {
    Task {
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let http = resp as? HTTPURLResponse
            print("[IMG DEBUG] status=", http?.statusCode ?? -1,
                  "mime=", http?.mimeType ?? "nil",
                  "bytes=", data.count)
        } catch {
            print("[IMG DEBUG] error:", error.localizedDescription)
        }
    }
}
