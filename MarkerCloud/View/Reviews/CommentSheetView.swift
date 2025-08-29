//
//  CommentSheetView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct CommentSheetView: View {
    let feedId: Int
    @StateObject private var reviewVM = ReviewVM()
    
    @State private var isWritingReview = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text(String(format: "평점 %.1f점", reviewVM.avgScore))
                        .foregroundColor(.secondary)
                    StarRatingView(rating: reviewVM.avgScore)
                    Spacer()
                }
                .font(.headline)
                .padding(.horizontal)
                
                Divider()
                List(reviewVM.reviews) { review in
                    HStack(spacing: 10) {
                        if let imageName = review.imageURL {
                            ReviewImage(url: imageName)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 50)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(review.content)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(formatReviewDate(review.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        StarRatingView(rating: review.score)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6)
                }
                .listRowInsets(EdgeInsets())
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                Button(action: {
                    isWritingReview = true
                }) {
                    Text("리뷰 작성하기")
                }
                .buttonStyle(FilledCTA())
                .padding()
                .sheet(isPresented: $isWritingReview) {
                    ReviewWriteView(feedId: feedId)
                }
            }
            .navigationTitle("리뷰")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await reviewVM.fetch(feedId: feedId)
            }
        }
    }
}
struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                let filled = Double(index + 1)
                if filled <= rating {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color("Main"))
                } else if filled - 0.5 <= rating {
                    Image(systemName: "star.leadinghalf.filled")
                        .foregroundColor(Color("Main"))
                } else {
                    Image(systemName: "star")
                        .foregroundColor(Color("Main"))
                }
            }
        }
    }
}
struct ReviewImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .clipped()
            case .failure(_):
                Image(systemName: "photo")
                    .resizable().scaledToFit().padding(24)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.secondary)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            default:
                ProgressView()
                    .frame(width: 50, height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
private let _reviewTimeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "ko_KR")
    df.timeZone = TimeZone(identifier: "Asia/Seoul")
    df.dateFormat = "HH:mm"
    return df
}()

private let _reviewFullFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "ko_KR")
    df.timeZone = TimeZone(identifier: "Asia/Seoul")
    df.dateFormat = "yyyy.MM.dd HH:mm"
    return df
}()

func formatReviewDate(_ date: Date?) -> String {
    guard let date = date else { return "" }
    //let cal = Calendar(identifier: .gregorian)
//    if cal.isDateInToday(date) {
//        return "오늘 " + _reviewTimeFormatter.string(from: date)
//    } else if cal.isDateInYesterday(date) {
//        return "어제 " + _reviewTimeFormatter.string(from: date)
//    } else {
//        return _reviewFullFormatter.string(from: date)
//    }
    return _reviewFullFormatter.string(from: date)
}
