//
//  MoreStoreView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI

struct MoreStoreView: View {
    let searchResultStore: [SearchResultStore]
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    
    var body: some View {
        NavigationStack {
            if searchResultStore.isEmpty {
                HStack {
                    Spacer()
                    Text("검색 결과가 없습니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .navigationTitle(Text("점포 더보기"))
            } else {
                Form {
                    Section(header: Text("점포 목록")) {
                        ForEach(searchResultStore) { store in
                            NavigationLink(
                                destination: StoreProfileView(
                                    storeId: store.id,
                                    appUser: appUser,
                                    selectedMarketID: $selectedMarketID
                                )
                            ) {
                                HStack(spacing: 16) {
                                    if let url = store.imgURL {
                                        
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            Circle()
                                                .fill(Color(.systemGray5))
                                                .frame(width: 40, height: 40)
                                        }
                                    } else {
                                        Circle().fill(Color(.systemGray5))
                                            .overlay(Image(systemName: "photo"))
                                            .frame(width: 40, height: 40)
                                    }
                                    Text(store.name)
                                        .font(.body)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }.navigationTitle("점포 더보기")
    }
}
