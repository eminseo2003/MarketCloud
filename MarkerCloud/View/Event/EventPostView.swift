//
//  EventDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

//import SwiftUI
//
//struct EventPostView: View {
//    var ismyEvent: Bool = true
//    let feed: Feed
//    private var firstStore: Store? {
//        dummyStores.first
//    }
//    let columns = [
//        GridItem(.flexible())
//    ]
//    @State private var pushEvent: Feed? = nil
//    var body: some View {
//        VStack {
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 8) {
//                    VStack(spacing: 16) {
//                        if let store = firstStore {
//                            EventCardView(feed: feed, store: store)
//                        }
//                        
//                    }
//                    .padding(.horizontal)
//                }
//                .padding(.top, 10)
//            }
//            if ismyEvent {
//                Button(action: {
//                    pushEvent = feed
//                }) {
//                    Text("이벤트 상세보기")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .font(.body)
//                        .padding()
//                        .background(Color("Main"))
//                        .cornerRadius(12)
//                }.padding(.horizontal)
//            }
//            
//        }
//        .navigationTitle(Text(feed.title))
//        .navigationDestination(item: $pushEvent) { feed in
//            EventDetailView(event: feed)
//        }
//        
//    }
//}
