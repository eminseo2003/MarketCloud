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
    @StateObject private var storeVm = StoreHeaderVM()
    //@StateObject private var likeVM = FeedLikeVM()
    
    let appUser: AppUser?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                pushStoreId = feed.storeId
            } label: {
                HStack {
                    StoreAvatarView(url: storeVm.profileURL, size: 30)
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
//                        feed.isLiked.toggle()
//                        feed.likeCount += feed.isLiked ? 1 : -1
//                        if feed.likeCount < 0 { feed.likeCount = 0 }
//                        
//                         Task {
//                            if let dto = await likeVM.toggle(feedId: feed.id, userId: currentUserID) {
//                                feed.isLiked = dto.isLiked
//                                feed.likeCount = dto.likesCount
//                            } else {
//                                feed.isLiked.toggle()
//                                feed.likeCount += feed.isLiked ? 1 : -1
//                            }
//                        }
                    } label: {
                        Image(systemName: "heart")
                        //Image(systemName: feed.isLiked ? "heart.fill" :"heart")
                            .font(.title3)
                            .foregroundColor(.primary)
                            //.foregroundColor(feed.isLiked ? Color("Main") :.primary)
                    }
                    Text("0")
                    //Text("\(feed.likeCount)")
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
                    Text("0")
                    //Text("\(feed.reviewCount)")
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .bold()
                }
                Spacer()
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
        .task { await storeVm.load(storeId: feed.storeId) }
//        .sheet(isPresented: $isCommentSheetPresented) {
//            CommentSheetView(feedId: feed.id)
//                .presentationDetents([.medium])
//        }
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
