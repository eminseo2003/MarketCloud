//
//  MyFollowingView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct MyFollowingView: View {
    @StateObject private var vm = FollowingStoresVM()
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("불러오는 중…")
                    .navigationTitle("구독한 점포")
            } else if vm.stores.isEmpty {
                HStack {
                    Spacer()
                    Text("구독한 점포가 없습니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .navigationTitle("구독한 점포")
            } else {
                Form {
                    Section(header: Text("점포 목록")) {
                        ForEach(vm.stores) { store in
                            NavigationLink(
                                destination: StoreProfileView(
                                    storeId: store.id ?? "",
                                    appUser: appUser,
                                    selectedMarketID: $selectedMarketID
                                )
                            ) {
                                HStack(spacing: 16) {
                                    if let url = store.imageURL {
                                        
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
        .onAppear {
            if let uid = appUser?.id ?? appUser?.id {
                vm.start(userId: uid)
            }
        }
        .onDisappear { vm.stop() }
    }
}

