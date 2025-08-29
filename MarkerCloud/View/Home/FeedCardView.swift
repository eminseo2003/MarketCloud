//
//  ProductCardView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct FeedCardView: View {
    @Binding var feed: Feed
    @State private var isCommentSheetPresented = false
    @Binding var pushStoreName: String?
    @StateObject private var likeVM = FeedLikeVM()
    let currentUserID: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Button {
                pushStoreName = feed.storeName
            } label: {
                HStack {
                    AsyncImage(url: feed.storeImageURL) { image in
                        //AsyncImage(url: kDummyImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feed.storeName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(formatDate(from: feed.createdAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }.padding(.horizontal)
            
            AsyncImage(url: feed.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Button {
                        // 1) 옵티미스틱 UI
                        feed.isLiked.toggle()
                        feed.likeCount += feed.isLiked ? 1 : -1
                        if feed.likeCount < 0 { feed.likeCount = 0 }
                        
                         Task {
                            if let dto = await likeVM.toggle(feedId: feed.id, userId: currentUserID) {
                                // 서버 값으로 최종 동기화
                                feed.isLiked = dto.isLiked
                                feed.likeCount = dto.likesCount
                            } else {
                                // 실패 시 되돌리기(선택)
                                feed.isLiked.toggle()
                                feed.likeCount += feed.isLiked ? 1 : -1
                            }
                        }
                    } label: {
                        Image(systemName: feed.isLiked ? "heart.fill" :"heart")
                            .font(.title3)
                            .foregroundColor(feed.isLiked ? Color("Main") :.primary)
                    }
                    Text("\(feed.likeCount)")
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
                    Text("\(feed.reviewCount)")
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
                Text(" \(feed.content)")
            )
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .sheet(isPresented: $isCommentSheetPresented) {
            CommentSheetView(feedId: feed.id)
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


