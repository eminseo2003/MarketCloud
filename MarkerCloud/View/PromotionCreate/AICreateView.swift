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
    @Binding var currentUserID: Int
    
    var body: some View {
        VStack(spacing: 0) {
            
            if hasStore {
                PromotionSelectView(currentUserID: $currentUserID)
            } else {
                NoStoreView(ismypage: ismypage, currentUserID: $currentUserID)
            }
            
        }
        
    }
}
