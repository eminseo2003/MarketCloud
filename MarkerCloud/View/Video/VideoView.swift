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
//struct VideoView: View {
//    let videoFeeds: [Feed]
//    @State private var page: Int? = 0
//    @State private var lastActive: Int = 0
//    @Binding var selectedMarketID: String
//    var body: some View {
//            ScrollView(.vertical) {
//                LazyVStack(spacing: 0) {
//                    ForEach(Array(videoFeeds.enumerated()), id: \.offset) { index, feed in
//                        let activeIndex = page ?? lastActive
//                        let isActive = activeIndex == index
//
//                        VideoPostFullScreenView(feed: feed, isActive: isActive)
//                            .id(index)
//                            .containerRelativeFrame(.vertical, count: 1, spacing: 0)
//                            .background(Color.black)
//                            .onAppear {
//                                print("📺 [VideoView] cell \(index) onAppear, isActive=\(isActive)")
//                            }
//                            .onDisappear {
//                                print("📺 [VideoView] cell \(index) onDisappear")
//                            }
//                            .onChange(of: isActive, initial: true) { _, newValue in
//                                print("🔄 [VideoView] cell \(index) isActive -> \(newValue)")
//                                if newValue {
//                                    print("▶️ [VideoView] cell \(index) became ACTIVE, url=\(feed.mediaUrl.absoluteString)")
//                                } else {
//                                    print("⏸️ [VideoView] cell \(index) became INACTIVE")
//                                }
//                            }
//                    }
//                }
//                .scrollTargetLayout()
//            }
//            .background(Color.black.ignoresSafeArea())
//            .scrollIndicators(.hidden)
//            .scrollTargetBehavior(.paging)
//            .scrollPosition(id: $page, anchor: .center)
//            .ignoresSafeArea()
//
//            // 처음 진입 시 혹시 nil이면 0으로 고정
//            .onAppear {
//                if page == nil { page = 0 }
//            }
//
//            // page 변화 로깅 + nil이 아닐 때에만 lastActive 갱신
//            .onChange(of: page, initial: true) { _, newPage in
//                print("📍 [VideoView] page -> \(String(describing: newPage))")
//                if let p = newPage { lastActive = p }
//            }
//        }
//    }
