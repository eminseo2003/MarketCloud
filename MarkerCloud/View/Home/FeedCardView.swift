//
//  ProductCardView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct FeedCardView: View {
    let feed: Feed
    @State private var isCommentSheetPresented = false
    @Binding var pushStoreName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Button {
                //pushStoreName = feed.storeName
            } label: {
                HStack {
                    //AsyncImage(url: URL(string: feed.storeImageUrl)) { image in
                        AsyncImage(url: kDummyImageURL) { image in
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
                        Text(feed.prompt ?? "")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(formatDate(from: feed.created_at))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
            
            AsyncImage(url: URL(string: feed.mediaUrl)) { image in
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
                        
                    } label: {
                        Image(systemName: "heart")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    Text("0")
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
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .bold()
                }
                
                Spacer()
            }
            .padding(.vertical, 5)
            
            //피드 제목 필요
            Text(feed.body ?? "")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.bottom, 8)
        .sheet(isPresented: $isCommentSheetPresented) {
            Text("댓글 기능 준비중…")
                .presentationDetents([.medium])
        }
    }
}

private func parseServerDate(_ s: String) -> Date? {
    if s.contains("Z") || s.range(of: #"[+\-]\d{2}:\d{2}$"#, options: .regularExpression) != nil {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: s) { return d }
    }

    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.dateFormat = s.contains(".") ? "yyyy-MM-dd'T'HH:mm:ss.SSS" : "yyyy-MM-dd'T'HH:mm:ss"
    return f.date(from: s)
}

func formatDate(from raw: String) -> String {
    guard let date = parseServerDate(raw) else { return raw }
    let out = DateFormatter()
    out.locale = Locale(identifier: "ko_KR")
    out.timeZone = .current
    out.dateFormat = "yyyy년 M월 d일 HH:mm"
    return out.string(from: date)
}


