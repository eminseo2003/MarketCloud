//
//  MyFollowingView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct MyFollowingView: View {
    @State private var selectedStore: Store? = nil
    
    var body: some View {
        if dummyStores.isEmpty {
            HStack {
                Spacer()
                Text("검색 결과가 없습니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle(Text("구독한 점포"))
        } else {
            Form {
                Section(header: Text("점포 목록")) {
                    ForEach(dummyStores) { store in
                        NavigationLink(destination: StoreProfileView(store: store)) {
                            HStack(spacing: 16) {
                                AsyncImage(url: store.profileImageURL) { image in
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
                                Text(store.storeName)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                        
                    }
                }
            }
            .navigationTitle("구독한 점포")
        }
        
    }
}

