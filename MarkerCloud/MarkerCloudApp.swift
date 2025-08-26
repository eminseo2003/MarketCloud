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
    var body: some Scene {
        WindowGroup {
            //RootRouterView(selectedMarketID: $selectedMarketID)
            StartView()
        }
    }
}
struct RootRouterView: View {
    @Binding var selectedMarketID: String

    var body: some View {
        Group {
            if selectedMarketID.isEmpty {
                MarketSelectionView(selectedMarketID: $selectedMarketID)
            } else {
                ContentView(selectedMarketID: $selectedMarketID)
            }
        }
    }
}
