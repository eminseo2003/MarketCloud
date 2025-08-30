//
//  MarkerCloudApp.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

@main
struct MarkerCloudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var session = SessionStore()
    
    @AppStorage("selectedMarketID") private var selectedMarketID: Int = -1
    @AppStorage("currentUserID")  private var currentUserID:  Int = -1
    
    var body: some Scene {
        WindowGroup {
            RootRouterView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
                .environmentObject(session)
        }
    }
}

struct RootRouterView: View {
    @EnvironmentObject var session: SessionStore
    @Binding var selectedMarketID: Int
    @Binding var currentUserID: Int
    
    var body: some View {
        Group {
            if session.authUser == nil {
                StartView()
            } else if selectedMarketID == -1 {
                MarketSelectionView(selectedMarketID: $selectedMarketID)
            } else {
                ContentView(selectedMarketID: $selectedMarketID, appUser: session.appUser)
            }
        }
    }
}
