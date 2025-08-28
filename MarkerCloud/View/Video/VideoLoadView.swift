//
//  VideoView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI
import AVKit

struct VideoLoadView: View {
    @StateObject private var videoVM = VideoFeedVM()
    @Binding var selectedMarketID: String
    var body: some View {
        Group {
            if videoVM.isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
            } else if let err = videoVM.errorMessage {
                HStack { Spacer(); Text(err).foregroundColor(.secondary); Spacer() }
            } else {
                VideoView(
                    videoVM: videoVM,
                    selectedMarketID: $selectedMarketID
                )
            }
        }
        .task { await videoVM.fetch() }
    }
}
