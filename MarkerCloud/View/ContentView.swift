//
//  ContentView.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Text 5")
            //MainView(selectedMarketID: $selectedMarketID, appUser: appUser)
                .tabItem { Label("홈", systemImage: "house") }
                .tag(0)
            
            Text("Text 5")
            //SearchView(selectedMarketID: $selectedMarketID, appUser: appUser)
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(1)
            
            
            Text("Text 5")
            //AICreateView(selectedMarketID: $selectedMarketID, appUser: appUser)
                .tabItem { Label("작성", systemImage: "plus.circle") }
                .tag(2)
            
            Text("Text 5")
            //VideoLoadView(selectedMarketID: $selectedMarketID, appUser: appUser)
                .tabItem { Label("영상", systemImage: "play.rectangle") }
                .tag(3)

            Text("Text 5")
            //SettingsView(selectedMarketID: $selectedMarketID, currentUserID: $currentUserID)
                .tabItem { Label("마이페이지", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .tint(selectedTab == 3 ? .white : .accentColor)
        
    }
}
