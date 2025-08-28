//
//  MoreProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct MoreProductView: View {
    let searchResultProduct: [ProductRow]
    @State private var route: Route? = nil
    @State private var selectedProduct: Feed? = nil
    
    var body: some View {
        if searchResultProduct.isEmpty {
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
                    ForEach(searchResultProduct) { product in
                        FeedCard(
                            title: product.name,
                            url: product.mediaURL,
                            likeCount: product.likeCount,
                            selectedFeed: $selectedProduct
                        )
                    }
                }
                .padding(.horizontal)
            }
//            .navigationDestination(item: $selectedProduct) { product in
//                //FeedView(feed: product)
//            }
            .navigationTitle(Text("상품 더보기"))
        }
        
    }
}
