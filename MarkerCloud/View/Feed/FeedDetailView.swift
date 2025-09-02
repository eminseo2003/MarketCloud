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
                ProductFeedDetail(feedId: feedId, appUser: appUser, selectedMarketID: $selectedMarketID)
            } else {
                EventDetailView(feedId: feedId, appUser: appUser, selectedMarketID: $selectedMarketID)
            }
        }
        
            .onAppear {
                Task {
                    await vm.load(feedId: feedId)
                }
            }
    }
}
