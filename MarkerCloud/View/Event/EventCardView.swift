//
//  EventCardView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct EventCardView: View {
    let feed: Feed
    let store: Store
    @State private var isCommentSheetPresented = false
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: store.profileImageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                    
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.storeName)
                        .font(.headline)
                    Text(formatDate(feed.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            AsyncImage(url: feed.mediaUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
                
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Button(action: {
                            //event.isLiked.toggle()
                        }) {
                            Image(systemName: "heart")
                                .font(.title3)
                                .foregroundColor(.primary)
//                            Image(systemName: event.isLiked ? "heart.fill" : "heart")
//                                .font(.title3)
//                                .foregroundColor(event.isLiked ? Color("Main") : .primary)
                            
                        }
                        Text("16")
                                .font(.footnote)
                                .foregroundColor(.primary)
                                .bold(true)
                    }
                    HStack(spacing: 2) {
                        Button(action: {
                            isCommentSheetPresented = true
                        }) {
                            Image(systemName: "bubble")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $isCommentSheetPresented) {
                            CommentSheetView(reviews: feed.reviews, feed: feed)
                                .presentationDetents([.medium])
                        }
                        Text("16")
                                .font(.footnote)
                                .foregroundColor(.primary)
                                .bold()
                    }
                    Spacer()
                    
                }
                .padding(.vertical, 5)
                
                
                (
                    Text(feed.title).bold() +
                    Text(" \(feed.body)")
                )
                .font(.subheadline)
                .foregroundColor(.primary)

                
                
            }
            
        }
    }
}
