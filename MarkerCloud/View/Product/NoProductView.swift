//
//  NoProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/18/25.
//

import SwiftUI

struct NoProductView: View {
    @StateObject private var storeDetail = StoreDetail()
    @State private var route: Route? = nil
    private let productPromotion = Promotion(name: "상품", imageName: "loginBackground")
    @State private var pushPromotion: Promotion? = nil
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
        var body: some View {
            VStack(spacing: 0) {
                
                ZStack {
                    VStack(spacing: 12) {
                        Image(systemName: "bag")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("등록된 상품이 없습니다.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    VStack(spacing: 12) {
                        Spacer()
                        Button(action: {
                            pushPromotion = productPromotion
                        }) {
                            Text("상품 등록하기")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .font(.body)
                                .padding()
                                .background(Color("Main"))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                
            }
            
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGray6).ignoresSafeArea())
                .navigationDestination(item: $pushPromotion) { promo in
                    PromotionMethodSelectView(promotion: promo, appUser: appUser, selectedMarketID: $selectedMarketID)
                }
            
        }
    }

