////
////  VideoView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/16/25.
////
//
//import SwiftUI
//import AVKit
//
//struct VideoLoadView: View {
//    @StateObject private var videoVM = VideoFeedVM()
//    @Binding var selectedMarketID: Int
//    @Binding var currentUserID: Int
//    
//    @State private var pushStore: Int? = nil
//    @StateObject private var vm = StoreProfileVM()
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                if videoVM.isLoading {
//                    HStack { Spacer(); ProgressView(); Spacer() }
//                } else if let err = videoVM.errorMessage {
//                    HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
//                } else {
//                    VideoView(
//                        videoVM: videoVM,
//                        selectedMarketID: $selectedMarketID, currentUserID: $currentUserID
//                    )
//                }
//            }
//            .task { await videoVM.fetch() }
//            .navigationDestination(item: $pushStore) { id in
//                if let storeId = pushStore {
//                    StoreProfileView(storeId: storeId, currentUserID: currentUserID)
//                } else {
//                    Text("잘못된 점포입니다.")
//                }
//            }
//        }
//        
//    }
//}
