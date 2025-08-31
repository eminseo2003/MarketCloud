//
//  AICreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI

struct AICreateView: View {
    var hasStore: Bool = false
    var ismypage: Bool = false
    
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    var body: some View {
        VStack(spacing: 0) {
            
            if hasStore {
                //PromotionSelectView(appUser: appUser)
            } else {
                NoStoreView(ismypage: ismypage, appUser: appUser)
            }
            
        }
        
    }
}
