//
//  CommentSheetView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct CompleteRecommendView: View {
    @State private var route: Route? = nil
    @Binding var selectedMarketID: Int
    @StateObject private var vm = MarketListVM()
    
    let topMarketName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .center, spacing: 24) {
                        VStack {
                            LazyVGrid(columns: [GridItem()], spacing: 8) {
                                MarketRecommandImage(assetName: vm.assetName(forMarketName: topMarketName))
                            }
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("추천 드리는 시장은 \(topMarketName)이에요")
                                .font(.title3).bold()
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("시장 주소")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                    )
                }
                .padding(16)
                Spacer()
                HStack(spacing: 10) {
                    Button(action: {
                        route = .selextMarket
                    }) {
                        Text("다른 시장 선택하기")
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Main"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("Main"), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        selectedMarketID = vm.marketCode(forMarketName: topMarketName)
                        withAnimation { dismiss() }
                    }) {
                        Text("이 시장 둘러보기")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Main"))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .navigationDestination(item: $route) { route in
                    if route == .selextMarket {
                        MarketSelectionView(selectedMarketID: $selectedMarketID)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("시장추천받기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct MarketRecommandImage: View {
    let assetName: String

    var body: some View {
        Image("market1")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .clipped()
    }
}
