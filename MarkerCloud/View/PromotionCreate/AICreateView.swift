//
//  AICreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI

struct AICreateView: View {
    @StateObject private var vm = StoreMembershipVM()
    var ismypage: Bool = false
    
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView("확인 중…")
            } else if vm.hasStore {
                NoStoreView(ismypage: false, appUser: appUser, selectedMarketID: $selectedMarketID)
                Text("내 점포가 있는 시장이에요!")
            } else {
                PromotionSelectView(appUser: appUser)
            }
            
        }
        .task(id: selectedMarketID) {
                    await vm.refresh(uid: appUser?.id, marketId: selectedMarketID)
                }
        
    }
}
