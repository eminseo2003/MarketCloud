//
//  MarketSelectionView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct MarketSelectionView: View {
    @Binding var selectedMarketID: Int
    @StateObject private var vm = MarketListVM()
    
    @State private var selectedChoice: Int? = nil
    @State private var route: Route? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
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
                
                Text("먼저 둘러볼 시장을 선택해주세요")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Group {
                    if vm.isLoading {
                        ProgressView().padding()
                    } else if let err = vm.errorMessage {
                        VStack(spacing: 8) {
                            Text("불러오기 실패").font(.headline)
                            Text(err).foregroundColor(.secondary)
                            Button("다시 시도") {
                                Task { await vm.fetch() }
                            }
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(vm.markets) { market in
                                    Button {
                                        selectedChoice = market.code
                                    } label: {
                                        MarketCardView(
                                            name: market.name,
                                            assetName: market.imageAssetName,
                                            isSelected: selectedChoice == market.code
                                        )
                                        .aspectRatio(1, contentMode: .fit)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            
                        }
                    }
                    
                }
                
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: {
                        route = .recommendMarket
                    }) {
                        Text("시장 추천받기")
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
                        if let choice = selectedChoice {
                            selectedMarketID = choice
                        }
                    }) {
                        Text("선택")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Main"))
                            .cornerRadius(10)
                    }.disabled(selectedChoice == nil)
                }
                .padding()
                .navigationDestination(item: $route) { route in
                    if route == .recommendMarket {
                        RecommendMarketView(selectedMarketID: $selectedMarketID)
                    }
                }
            }
            
        }
        .task {
            await vm.fetch()
        }
        .refreshable {
            await vm.fetch()
        }
        
        
    }
}

struct MarketCardView: View {
    let name: String
    let assetName: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 180)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
                .grayscale(isSelected ? 0 : 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color("Main") : .clear, lineWidth: 3)
                )
                .cornerRadius(12)
                .overlay( // 텍스트 가독성용 그라데이션
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.0), .black.opacity(0.5)]),
                        startPoint: .top, endPoint: .bottom
                    )
                    .cornerRadius(12)
                )
            
            Text(name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .frame(maxWidth: .infinity)
                .shadow(radius: 4)
        }
    }
}
