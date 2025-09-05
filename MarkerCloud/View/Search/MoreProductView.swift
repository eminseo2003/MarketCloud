//
//  MoreProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct MoreProductView: View {
    let searchResultProduct: [SearchResultFeed]
    @State private var route: Route? = nil
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    @State private var selectedFeedId: String? = nil
    @State private var selectedStoreId: String? = nil
    
    var body: some View {
        NavigationStack {
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
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(searchResultProduct) { p in
                            NavigationLink(
                                destination: FeedView(
                                    feedId: p.id,
                                    appUser: appUser,
                                    storeId: p.storeId,
                                    selectedMarketID: $selectedMarketID
                                )
                            ) {
                                MoreMediaThumbCard(title: p.name, url: p.mediaURL, likeCount: p.likeCount,feedId: p.id, appUser: appUser)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationTitle(Text("상품 더보기"))
            }
            
            
        }
    }
}
