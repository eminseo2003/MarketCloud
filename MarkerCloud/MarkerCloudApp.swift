//
//  MarkerCloudApp.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import SwiftUI


@main
struct MarkerCloudApp: App {
    @AppStorage("selectedMarketID") private var selectedMarketID: String = ""
    @AppStorage("currentUserID") private var currentUserID: String = ""
    var body: some Scene {
        WindowGroup {
            //RootRouterView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
            ContentView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
        }
    }
}
struct RootRouterView: View {
    @Binding var selectedMarketID: String
    @Binding var currentUserID: String
    
    var body: some View {
        Group {
            if currentUserID.isEmpty {
                StartView(currentUserID: $currentUserID)
            } else if selectedMarketID.isEmpty {
                MarketSelectionView(selectedMarketID: $selectedMarketID)
            } else {
                ContentView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
            }
        }
    }
}
