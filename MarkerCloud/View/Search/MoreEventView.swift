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
    @State private var selectedEvent: Feed? = nil
    let appUser: AppUser?
    
    var body: some View {
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
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                    ForEach(searchResultEvent) { e in
                        MediaThumbCard(title: e.name, url: e.mediaURL, likeCount: e.likeCount,feedId: e.id, appUser: appUser)
                            .foregroundColor(.primary)
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
