//
//  MyProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/18/25.
//

import SwiftUI
import FirebaseAuth

struct MyProductView: View {
    @StateObject private var vm = MyProductVM()
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
    var hasProduct: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView("불러오는 중…")
            } else if vm.hasProduct {
                MyproductListView(productList: vm.products, appUser: appUser, selectedMarketID: $selectedMarketID)
            } else {
                NoProductView(selectedMarketID: $selectedMarketID, appUser: appUser)
                .background(Color(uiColor: .systemGray6).ignoresSafeArea())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("내 상품")
        .onAppear {
            guard let uid = appUser?.id ?? Auth.auth().currentUser?.uid else { return }
            // 시장별 필터를 쓰고 싶으면 marketId: selectedMarketID 전달
            vm.start(userId: uid, marketId: selectedMarketID, includeDrafts: false)
        }
        .onChange(of: selectedMarketID) { _, new in
            guard let uid = appUser?.id ?? Auth.auth().currentUser?.uid else { return }
            vm.start(userId: uid, marketId: new, includeDrafts: false)
        }
        .onDisappear {
            vm.stop()
        }
    }
}

