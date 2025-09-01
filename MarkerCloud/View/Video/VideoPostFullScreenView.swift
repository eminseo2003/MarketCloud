////
////  VideoPostView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/16/25.
////
//
//import SwiftUI
//import AVKit
//import AVFoundation
//import Combine
//
//struct VideoPostFullScreenView: View {
//    let video: VideoItemUI
//    let isActive: Bool
//    @State private var player: AVPlayer?
//    
//    @State private var itemStatus: AVPlayerItem.Status = .unknown
//    @State private var cancellables = Set<AnyCancellable>()
//    @State private var isCommentSheetPresented = false
//    @Environment(\.scenePhase) private var scenePhase
//    
//    @State private var userPaused = false
//    @State private var showHUD = false
//    
//    @State private var pushStore: Int? = nil
//    @Binding var currentUserID: Int
//
//    var body: some View {
//        ZStack {
//            if let player {
//                CustomVideoPlayerView(player: player, gravity: .resizeAspect)
//                            .ignoresSafeArea()
//                
//            } else {
//                Color.black.ignoresSafeArea()
//                ProgressView().tint(.white)
//            }
//            
//            
//            VStack {
//                Spacer()
//                HStack(alignment: .bottom) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        HStack {
//                            Text(video.name)
//                                .font(.body)
//                                .bold(true)
//                                .foregroundColor(.white)
//                                .lineLimit(1)
//                            
//                            Text(formattedDate(video.createdAt))
//                                .font(.caption)
//                                .foregroundColor(.white)
//                            Spacer()
//                        }
//                        
//                        Text(video.content)
//                            .font(.footnote)
//                            .foregroundColor(.white)
//                            .lineLimit(3)
//                    }
//                    Spacer()
//                    VStack(spacing: 16) {
//                        Button(action: {
//                            pushStore = video.storeId
//                        }) {
//                            if let url = video.storeImageURL {
//                                AsyncImage(url: url) { image in
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 32, height: 32)
//                                        .clipShape(Circle())
//                                } placeholder: {
//                                    Circle()
//                                        .fill(Color("Main").opacity(0.3))
//                                        .frame(width: 32, height: 32)
//                                }
//                            } else {
//                                Circle()
//                                    .fill(Color("Main").opacity(0.3))
//                                    .frame(width: 32, height: 32)
//                            }
//                        }
//                        
//                        
//                        VStack(spacing: 2) {
//                            Button(action: {
//                                
//                            }) {
//                                Image(systemName: "heart")
//                                    .frame(width: 32, height: 32)
//                                    .foregroundColor(.white)
//                                
//                            }
//                            Text("\(video.likeCount)")
//                                .font(.footnote)
//                                .foregroundColor(.white)
//                        }
//                        VStack(spacing: 2) {
//                            Button(action: {
//                                isCommentSheetPresented = true
//                            }) {
//                                Image(systemName: "bubble")
//                                    .frame(width: 32, height: 32)
//                                    .foregroundColor(.white)
//                            }
//                            .sheet(isPresented: $isCommentSheetPresented) {
//                                CommentSheetView(feedId: video.id)
//                                    presentationDetents([.medium])
//                                
//                            }
//                            Text("\(video.reviewCount)")
//                                .font(.footnote)
//                                .foregroundColor(.white)
//                        }
//                        
//                        
//                    }
//                    .padding(.bottom, 80)
//                }
//                .padding()
//            }
//        }
//        .task(id: video.url) { await preparePlayer(url: video.url) }
//        .padding(.bottom, 80)
//        .padding(.top, 24)
//        .onAppear {
//            if player == nil {
//                Task { await preparePlayer(url: video.url) }
//            }
//        }
//        .onChange(of: video.url) { _, newURL in
//            pauseAndTearDown()
//            Task { await preparePlayer(url: newURL) }
//        }
//        // 활성화되면: 준비가 끝났으면 재생, 아직이면 준비부터
//        .onChange(of: isActive, initial: true) { _, nowActive in
//            if nowActive {
//                if itemStatus == .readyToPlay {
//                    player?.play()
//                } else if player == nil {
//                    Task { await preparePlayer(url: video.url) }
//                }
//            } else {
//                // 비활성화되면 깔끔히 종료
//                pauseAndTearDown()
//            }
//        }
//        // 준비 상태가 ready가 되는 그 순간 재생 (가장 신뢰도 높음)
//        .onChange(of: itemStatus) { _, status in
//            if status == .readyToPlay, isActive {
//                player?.play()
//                // 필요시: player?.playImmediately(atRate: 1.0)
//            }
//        }
//        // player 갈아끼워지는 순간에도 한번 더 안전망
//        .onChange(of: player) { _, _ in
//            if itemStatus == .readyToPlay, isActive {
//                player?.play()
//            }
//        }
//        // 시트/앱 상태 변화
//        .onChange(of: isCommentSheetPresented) { _, shown in
//            if shown { player?.pause() }
//            else if isActive, itemStatus == .readyToPlay { player?.play() }
//        }
//        .onChange(of: scenePhase) { _, phase in
//            if phase != .active { player?.pause() }
//        }
//        .onDisappear { pauseAndTearDown() }
//        
//    }
//    private func pauseAndTearDown() {
//        player?.pause()
//        player?.replaceCurrentItem(with: nil)   // 아이템 제거 (오디오/디코딩 완전 중단)
//        player = nil
//        
//        cancellables.removeAll()
//        itemStatus = .unknown
//        
//        // 오디오 세션 비활성화(선택) — 다른 앱 소리 복귀
//        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//    }
//    
//    private func preparePlayer(url: URL?) async {
//        guard let url = url else {
//                print("preparePlayer called with nil URL")
//                pauseAndTearDown()
//                return
//            }
//        // 오디오 세션 (무음 스위치/백그라운드 대비)
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("AudioSession error:", error)
//        }
//        
//        // 기존 옵저버 해제
//        cancellables.removeAll()
//        
//        let asset = AVURLAsset(url: url)
//        do {
//            _ = try await asset.load(.isPlayable)
//            _ = try await asset.load(.duration)
//            
//            let item = AVPlayerItem(asset: asset)
//            // 버퍼링 정책(초기 재생 빠르게)
//            item.preferredForwardBufferDuration = 0
//            
//            await MainActor.run {
//                let p = AVPlayer(playerItem: item)
//                p.automaticallyWaitsToMinimizeStalling = false
//                self.player = p
//                self.itemStatus = .unknown
//                
//                item.publisher(for: \.status)
//                    .receive(on: RunLoop.main)
//                    .sink { status in
//                        self.itemStatus = status
//                    }
//                    .store(in: &cancellables)
//                
//                p.publisher(for: \.timeControlStatus)
//                    .receive(on: RunLoop.main)
//                    .sink { status in
//                        if status == .paused, self.isActive, self.itemStatus == .readyToPlay {
//                            self.player?.play()
//                        }
//                    }
//                    .store(in: &cancellables)
//                
//                NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
//                    .receive(on: RunLoop.main)
//                    .sink { note in
//                        guard
//                            let info = note.userInfo,
//                            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
//                            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
//                        else { return }
//                        if type == .ended, self.isActive, self.itemStatus == .readyToPlay {
//                            self.player?.play()
//                        }
//                    }
//                    .store(in: &cancellables)
//            }
//        } catch {
//            print("Asset load failed:", error)
//        }
//    }
//    func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
//        return formatter.string(from: date)
//    }
//}
