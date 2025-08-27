////
////  MyProductView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/18/25.
////
//
//import SwiftUI
//
//struct MyProductView: View {
//    var hasProduct: Bool = true
//    var filteredProducts: [Feed] {
//        dummyFeed
//            .filter { $0.promoKind == .product }
//    }
//    var body: some View {
//        VStack(spacing: 0) {
//            if hasProduct {
//                MyproductListView(productList: filteredProducts)
//            } else {
//                NoProductView()
//                    .background(Color(uiColor: .systemGray6).ignoresSafeArea())
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .navigationTitle("내 상품")
//    }
//}
//
