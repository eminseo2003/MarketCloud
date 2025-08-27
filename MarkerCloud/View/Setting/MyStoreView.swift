////
////  MyStoreView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/17/25.
////
//
//import SwiftUI
//
//struct MyStoreView: View {
//    var hasStore: Bool = true
//    var ismypage: Bool = true
//    private var firstStore: Store? {
//        dummyStores.first
//    }
//    var body: some View {
//        VStack(spacing: 0) {
//            if hasStore {
//                if let store = firstStore {
//                    StoreProfileView(store: store)
//                }
//            } else {
//                NoStoreView(ismypage: ismypage)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
//        .navigationTitle("내 점포")
//    }
//}
//
