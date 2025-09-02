//
//  ProductCardView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct FeedCardView: View {
    let feed: FeedItem
    @State private var isCommentSheetPresented = false
    @Binding var pushStoreId: String?
    @Binding var pushFeedId: String?
    let appUser: AppUser?
    @Binding var route: Route?
    @StateObject private var storeVm = StoreHeaderVM()
    @StateObject private var likeVM = FeedLikeVM()
    @StateObject private var reviewVM = ReviewListVM()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                pushStoreId = feed.storeId
            } label: {
                HStack {
                    StoreAvatarView(url: URL(string: storeVm.profileURL ?? ""), size: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(storeVm.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(formatDate(from: feed.createdAt ?? Date()))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }.padding(.horizontal)
            
            AsyncImage(url: feed.mediaUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Button {
                        Task { await likeVM.toggle() }
                    } label: {
                        Image(systemName: likeVM.isLiked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(likeVM.isLiked ? Color("Main") :.primary)
                    }
                    Text("\(likeVM.likesCount)")
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .bold()
                }
                
                HStack(spacing: 4) {
                    Button {
                        isCommentSheetPresented = true
                    } label: {
                        Image(systemName: "bubble")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    Text("\(reviewVM.reviewsCount)")
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .bold()
                }
                Spacer()
                Button {
                    pushFeedId = feed.id
                    print("pushFeedId : \(pushFeedId ?? "없음")")
//                    pushStoreId = feed.storeId
//                    print("pushStoreId : \(pushStoreId ?? "없음")")
                } label: {
                    HStack(spacing: 6) {
                        Text("더보기")
                    }
                    .font(.footnote).bold()
                    .padding(.horizontal,6)
                    .padding(.vertical,6)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
                    .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal)
            
            (
                Text(feed.title).bold() +
                Text(" \(feed.body)")
            )
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .task {
            await storeVm.load(storeId: feed.storeId)
            await reviewVM.load(feedId: feed.id)
            if let uid = appUser?.id {
                await likeVM.start(feedId: feed.id, userId: uid)
            }
        }
        .onDisappear { likeVM.stop() }
        .sheet(isPresented: $isCommentSheetPresented, onDismiss: {
            Task {
                await storeVm.load(storeId: feed.storeId)
                await reviewVM.load(feedId: feed.id)
            }
        }) {
            CommentSheetView(feedId: feed.id, appUser: appUser)
                .presentationDetents([.medium])
        }
    }
}

//private func parseServerDate(_ s: String) -> Date? {
//    if s.contains("Z") || s.range(of: #"[+\-]\d{2}:\d{2}$"#, options: .regularExpression) != nil {
//        let iso = ISO8601DateFormatter()
//        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        if let d = iso.date(from: s) { return d }
//        iso.formatOptions = [.withInternetDateTime]
//        if let d = iso.date(from: s) { return d }
//    }
//
//    let f = DateFormatter()
//    f.locale = Locale(identifier: "en_US_POSIX")
//    f.timeZone = TimeZone(secondsFromGMT: 0)
//    f.dateFormat = s.contains(".") ? "yyyy-MM-dd'T'HH:mm:ss.SSS" : "yyyy-MM-dd'T'HH:mm:ss"
//    return f.date(from: s)
//}

func formatDate(from raw: Date) -> String {
    let out = DateFormatter()
    out.locale = Locale(identifier: "ko_KR")
    out.timeZone = .current
    out.dateFormat = "yyyy년 M월 d일 HH:mm"
    return out.string(from: raw)
}
struct StoreAvatarView: View {
    let url: URL?
    var size: CGFloat = 48
    
    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "person.crop.circle.fill")
                .imageScale(.large)
                .foregroundColor(.gray)
        }
    }
}
