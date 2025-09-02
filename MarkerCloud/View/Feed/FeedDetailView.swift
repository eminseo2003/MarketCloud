//
//  FeedDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import SwiftUI

struct FeedDetailView: View {
    let feedId: String
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    
    @StateObject private var vm = FeedVM()
    
    var body: some View {
        Group{
            if vm.promoKind == "store" {
                StoreFeedDetail(feedId: feedId, appUser: appUser, selectedMarketID: $selectedMarketID)
            } else if vm.promoKind == "product" {
                Text("농담공상품")
            } else {
                Text("농담공이벤트")
            }
        }
        
            .onAppear {
                Task {
                    await vm.load(feedId: feedId)
                }
            }
    }
}
