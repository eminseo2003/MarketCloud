//
//  PromotionSelectView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct Promotion: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
}
struct PromotionSelectView: View {
    @State private var selectedPromotion: Promotion? = nil
    @State private var pushPromotion: Promotion? = nil
    let promotions: [Promotion] = [
        Promotion(name: "점포", imageName: "loginBackground"),
        Promotion(name: "상품", imageName: "loginBackground"),
        Promotion(name: "이벤트", imageName: "loginBackground")
    ]
    @State private var route: Route? = nil
    var hasSelection: Bool { selectedPromotion != nil }
    @Binding var currentUserID: Int
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image("screentoplogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text("Market Cloud")
                        .foregroundColor(.black)
                        .frame(height: 30)
                        .font(.title)
                        .bold(true)
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("홍보하실 상품을 선택해주세요")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                VStack(spacing: 16) {
                    ForEach(promotions) { promotion in
                        Button(action: {
                            if selectedPromotion?.id == promotion.id {
                                selectedPromotion = nil
                            } else {
                                selectedPromotion = promotion
                            }
                        }) {
                            PromotionCardView(
                                promotion: promotion,
                                isSelected: selectedPromotion?.id == promotion.id
                            )
                        }
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack {
                    Button {
                        pushPromotion = selectedPromotion
                    } label: {
                        Text("다음")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasSelection ? Color("Main") : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .disabled(!hasSelection)
                }
                .padding()
                .navigationDestination(item: $pushPromotion) { promo in
                    PromotionMethodSelectView(promotion: promo, currentUserID: $currentUserID)
                }
            }
            
        }
        
        
        
    }
}
struct PromotionCardView: View {
    let promotion: Promotion
    let isSelected: Bool
    
    var body: some View {
        ZStack() {
            Image(promotion.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .grayscale(isSelected ? 0 : 1)
                .cornerRadius(12)
            
            Text("\(promotion.name) 홍보")
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .frame(maxWidth: .infinity)
        }
    }
}
