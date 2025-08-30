//
//  MarkerCloudApp.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import SwiftUI
import FirebaseCore

@main
struct MarkerCloudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("selectedMarketID") private var selectedMarketID: Int = -1
    @AppStorage("currentUserID") private var currentUserID: Int = -1
    var body: some Scene {
        WindowGroup {
            RootRouterView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
            //ContentView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
        }
    }
}
struct RootRouterView: View {
    @Binding var selectedMarketID: Int
    @Binding var currentUserID: Int
    
    var body: some View {
        Group {
            if currentUserID == -1 {
                StartView(currentUserID: $currentUserID)
            } else if selectedMarketID == -1 {
                MarketSelectionView(selectedMarketID: $selectedMarketID)
            } else {
                ContentView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
