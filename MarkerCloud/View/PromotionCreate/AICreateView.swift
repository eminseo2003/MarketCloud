//
//  AICreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI
import FirebaseAuth

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
                PromotionSelectView(appUser: appUser)
                //Text("내 점포가 있는 시장이에요!")
            } else {
                NoStoreView(ismypage: false, appUser: appUser, selectedMarketID: $selectedMarketID)
            }
            
        }
        .onChange(of: appUser?.id) { _, newId in
            Task {
                guard let uid = newId else { return }
                await vm.refresh(appUserId: uid, marketId: selectedMarketID)
            }
        }
        .task(id: selectedMarketID) {
            guard let uid = appUser?.id ?? Auth.auth().currentUser?.uid else { return }
            await vm.refresh(appUserId: uid, marketId: selectedMarketID)
        }

        
    }
}
