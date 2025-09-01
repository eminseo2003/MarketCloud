//
//  AICreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI
import FirebaseAuth

struct AICreateView: View {
    @StateObject private var vm = StoreMembershipVM()
    var ismypage: Bool = false
    
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    
    private var ownerId: String? {
        appUser?.id ?? Auth.auth().currentUser?.uid
    }
    @State private var showCreatedAlert = false
    @State private var didShowCreateAlert = false
    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView("확인 중…")
            } else if vm.hasStore {
                PromotionSelectView(appUser: appUser, selectedMarketID: $selectedMarketID)
            } else {
                NoStoreView(ismypage: false, appUser: appUser, selectedMarketID: $selectedMarketID)
            }
            
        }
        // 화면 보일 때 구독 시작
        .onAppear {
            guard let uid = appUser?.id ?? Auth.auth().currentUser?.uid else { return }
            vm.start(ownerId: uid, marketId: selectedMarketID)
        }
        // 시장 바뀌면 다시 시작 + Alert 재허용
        .onChange(of: selectedMarketID) { _, newValue in
            didShowCreateAlert = false
            guard let uid = ownerId else { return }
            vm.start(ownerId: uid, marketId: newValue)
        }
        // hasStore가 false → true로 바뀌는 순간만 Alert 표시
        .onChange(of: vm.hasStore) { oldValue, newValue in
            if oldValue == false && newValue == true && !didShowCreateAlert {
                didShowCreateAlert = true
                showCreatedAlert = true
            }
        }
        // 로그인/유저 변경되면 다시 시작
        .onChange(of: appUser?.id) { _, newId in
            guard let uid = newId ?? Auth.auth().currentUser?.uid else { return }
            vm.start(ownerId: uid, marketId: selectedMarketID)
        }
        // 화면 사라지면 정리 (메모리/요금 절약)
        .onDisappear { vm.stop() }
        // 값 변화를 자연스럽게
        .animation(.default, value: vm.hasStore)
        // Alert 본문
        .alert("알림", isPresented: $showCreatedAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("점포 등록이 완료되었습니다.")
        }
    }
}
