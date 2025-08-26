//
//  ProductDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct FeedView: View {
    let feed: Feed
    private var firstStore: Store? {
        dummyStores.first
    }
    let columns = [
        GridItem(.flexible())
    ]
    @State private var pushFeed: Feed? = nil
    @State private var selectedStore: Store? = nil
    @State private var route: Route? = nil
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    VStack(spacing: 16) {
                        if let store = firstStore {
                            FeedCardView(feed: feed, store: store, pushStore: $selectedStore)
                        }
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
            Button(action: {
                pushFeed = feed
            }) {
                Text("피드 상세보기")
            }.buttonStyle(FilledCTA())
                .padding()
        }
        .navigationTitle(Text(feed.title))
        .navigationDestination(item: $pushFeed) { feed in
            if feed.promoKind == .store {
                
            } else if feed.promoKind == .product {
                ProductDetailView(product: feed)
            } else if feed.promoKind == .event {
                EventDetailView(event: feed)
            }
        }
        
    }
}
