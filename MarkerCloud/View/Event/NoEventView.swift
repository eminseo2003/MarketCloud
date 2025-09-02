//
//  NoEventView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

//class StoreDetail: ObservableObject {
//    @Published var businessType: String = ""
//    @Published var phoneNumber: String = ""
//    @Published var weekdayOpen: Date = Date()
//    @Published var weekdayClose: Date = Date()
//    @Published var weekendOpen: Date = Date()
//    @Published var weekendClose: Date = Date()
//    @Published var roadAddress: String = ""
//    @Published var jibunAddress: String = ""
//    @Published var usesVouchers: [String] = []
//    @Published var storeDescription: String = ""
//}

struct NoEventView: View {
    @StateObject private var storeDetail = StoreDetail()
    @State private var route: Route? = nil
    private let eventPromotion = Promotion(name: "이벤트", imageName: "loginBackground")
    @State private var pushPromotion: Promotion? = nil
    @Binding var selectedMarketID: Int
    let appUser: AppUser?
        var body: some View {
            VStack(spacing: 0) {
                
                ZStack {
                    VStack(spacing: 12) {
                        Image(systemName: "ticket")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("등록된 이벤트가 없습니다.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    VStack(spacing: 12) {
                        Spacer()
                        Button(action: {
                            pushPromotion = eventPromotion
                        }) {
                            Text("이벤트 등록하기")
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

