//
//  MoreProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct MoreProductView: View {
    let filteredProducts: [Feed]
    @State private var route: Route? = nil
    @State private var selectedProduct: Feed? = nil
    
    var body: some View {
        if filteredProducts.isEmpty {
            HStack {
                Spacer()
                Text("검색 결과가 없습니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle(Text("상품 더보기"))
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                    ForEach(filteredProducts) { product in
                        FeedCard(feed: product, selectedFeed: $selectedProduct)
                    }
                }
                .padding(.horizontal)
            }
            .navigationDestination(item: $selectedProduct) { product in
                FeedView(feed: product)
            }
            .navigationTitle(Text("상품 더보기"))
        }
        
    }
}
