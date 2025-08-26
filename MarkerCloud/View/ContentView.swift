//
//  ContentView.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var selectedMarketID: String
    @State private var selectedTab: Int = 0
    
    var videoFeeds: [Feed] {
        dummyFeed.filter { $0.mediaType == .video }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView(selectedMarketID: $selectedMarketID)
                .tabItem { Label("홈", systemImage: "house") }
                .tag(0)
            
            SearchView(selectedMarketID: $selectedMarketID)
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(1)
            
            AICreateView(selectedMarketID: $selectedMarketID)
                .tabItem { Label("작성", systemImage: "plus.circle") }
                .tag(2)
            
            VideoView(videoFeeds: videoFeeds, selectedMarketID: $selectedMarketID)
                .tabItem { Label("영상", systemImage: "play.rectangle") }
                .tag(3)
            
            SettingsView(selectedMarketID: $selectedMarketID)
                .tabItem { Label("마이페이지", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .tint(selectedTab == 3 ? .white : .accentColor)
        
    }
}
