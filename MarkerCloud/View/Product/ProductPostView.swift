//
//  ProductDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct ProductPostView: View {
    var ismyProduct: Bool = true
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
                            ProductCardView(feed: feed, store: store, route: $route, selectedStore: $selectedStore)
                        }
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
            if ismyProduct {
                Button(action: {
                    pushFeed = feed
                }) {
                    Text("상품 상세보기")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                }.padding(.horizontal)
            }
            
        }
        .navigationTitle(Text(feed.title))
        .navigationDestination(item: $pushFeed) { feed in
            //ProductDetailView(feed: feed)
        }
        
    }
}
