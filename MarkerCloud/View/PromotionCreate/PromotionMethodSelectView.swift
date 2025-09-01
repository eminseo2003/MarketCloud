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
    let mediaType: MediaType
}
struct PromotionMethodSelectView: View {
    let promotion: Promotion
    
    @State private var selectedMethod: Method? = nil
    @State private var pushMethod: Method? = nil
    let methods: [Method] = [
        Method(name: "사진", imageName: "loginBackground", mediaType: .image),
        Method(name: "동영상", imageName: "loginBackground", mediaType: .video)
    ]
    @State private var isCreateViewShow = false
    var hasSelection: Bool { selectedMethod != nil }
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    
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
                            CreateStoreView(
                                feedType: mapFeedType(from: promotion.name),
                                method: pushMethod?.mediaType ?? .image,
                                appUser: appUser, selectedMarketID: selectedMarketID
                            )
//                        } else if promotion.name == "상품"{
//                            CreateProductView(
//                                feedType: mapFeedType(from: promotion.name),
//                                method: pushMethod?.mediaType ?? .image,
//                                appUser: appUser
//                            )
//                        } else {
//                            CreateEventView(
//                                feedType: mapFeedType(from: promotion.name),
//                                method: pushMethod?.mediaType ?? .image,
//                                appUser: appUser
//                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("\(promotion.name) 홍보 생성하기")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func mapFeedType(from name: String) -> FeedType {
            switch name {
            case "점포":  return .store
            case "상품":  return .product
            case "이벤트": return .event
            default:      return .event
            }
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
