////
////  MoreEventView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/16/25.
////
//
//import SwiftUI
//
//struct MoreEventView: View {
//    let searchResultEvent: [EventRow]
//    @State private var route: Route? = nil
//    @State private var selectedEvent: Feed? = nil
//    
//    var body: some View {
//        if searchResultEvent.isEmpty {
//            HStack {
//                Spacer()
//                Text("검색 결과가 없습니다.")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                Spacer()
//            }
//            .navigationTitle(Text("이벤트 더보기"))
//        } else {
//            ScrollView {
//                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
//                    ForEach(searchResultEvent) { event in
//                        FeedCard(
//                            title: event.name,
//                            url: event.mediaURL,
//                            likeCount: event.likeCount,
//                            selectedFeed: $selectedEvent
//                        )
//                    }
//                }
//                .padding(.horizontal)
//            }
////            .navigationDestination(item: $selectedEvent) { event in
////                FeedView(feed: event)
////            }
//            .navigationTitle(Text("이벤트 더보기"))
//        }
//        
//        
//        
//    }
//}
