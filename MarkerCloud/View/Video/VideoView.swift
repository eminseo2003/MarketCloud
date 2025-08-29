//
//  VideoView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject var videoVM: VideoFeedVM
    @State private var page: Int? = 0
    @State private var lastActive: Int = 0
    @Binding var selectedMarketID: Int
    
    var body: some View {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(videoVM.videos.indices, id: \.self) { index in
                        let item = videoVM.videos[index]
                        let activeIndex = page ?? lastActive
                        let isActive = (activeIndex == index)

                        VideoPostFullScreenView(video: item, isActive: isActive)
                            .id(index)
                            .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                            .background(Color.black)
                            .onAppear {
                                print("[VideoView] cell \(index) onAppear, isActive=\(isActive)")
                            }
                            .onDisappear {
                                print("[VideoView] cell \(index) onDisappear")
                            }
                            .onChange(of: isActive, initial: true) { _, newValue in
                                print("[VideoView] cell \(index) isActive -> \(newValue)")
                                if newValue {
                                    print("[VideoView] cell \(index) became ACTIVE url=\(item.url?.absoluteString ?? "nil")")
                                } else {
                                    print("[VideoView] cell \(index) became INACTIVE")
                                }
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .background(Color.black.ignoresSafeArea())
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $page, anchor: .center)
            .ignoresSafeArea()

            // 처음 진입 시 혹시 nil이면 0으로 고정
            .onAppear {
                if page == nil { page = 0 }
            }

            // page 변화 로깅 + nil이 아닐 때에만 lastActive 갱신
            .onChange(of: page, initial: true) { _, newPage in
                print("[VideoView] page -> \(String(describing: newPage))")
                if let p = newPage { lastActive = p }
            }
        }
    }
