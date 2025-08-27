//
//  AICreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI

struct AICreateView: View {
    var hasStore: Bool = true
    var ismypage: Bool = false
    
    @Binding var selectedMarketID: String
    var body: some View {
        VStack(spacing: 0) {
            
            if hasStore {
                PromotionSelectView()
            } else {
                NoStoreView(ismypage: ismypage)
            }
            
        }
        
    }
}
