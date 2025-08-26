//
//  PromotionMethodSelectView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct Method: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}
struct PromotionMethodSelectView: View {
    let promotion: Promotion
    
    @State private var selectedMethod: Method? = nil
    @State private var pushMethod: Method? = nil
    let methods: [Method] = [
        Method(name: "사진", imageName: "loginBackground"),
        Method(name: "동영상", imageName: "loginBackground")
    ]
    @State private var isCreateViewShow = false
    var hasSelection: Bool { selectedMethod != nil }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                Text("홍보하실 방법을 선택해주세요")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                VStack(spacing: 16) {
                    ForEach(methods) { method in
                        Button(action: {
                            if selectedMethod?.id == method.id {
                                selectedMethod = nil
                            } else {
                                selectedMethod = method
                            }
                        }) {
                            PromotionMethodCardView(
                                method: method,
                                isSelected: selectedMethod?.id == method.id
                            )
                        }
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack {
                    Button {
                        pushMethod = selectedMethod
                        isCreateViewShow = true
                        print(promotion.name)
                        print(pushMethod!.name)
                        
                    } label: {
                        Text("생성하기")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasSelection ? Color("Main") : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .disabled(!hasSelection)
                    .sheet(item: $pushMethod) { method in
                        if promotion.name == "점포"{
                            CreateStoreView(method: method, promotion: promotion)
                        } else if promotion.name == "상품"{
                            CreateProductView(method: method, promotion: promotion)
                        } else {
                            CreateEventView(method: method, promotion: promotion)
                        }
                    }
                    
                    
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("\(promotion.name) 홍보 생성하기")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    
}

struct PromotionMethodCardView: View {
    let method: Method
    let isSelected: Bool
    
    var body: some View {
        ZStack() {
            Image(method.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .grayscale(isSelected ? 0 : 1)
                .cornerRadius(12)
            
            Text("\(method.name)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .frame(maxWidth: .infinity)
        }
    }
}
