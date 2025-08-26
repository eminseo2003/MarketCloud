//
//  MarketSelectionView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct MarketSelectionView: View {
    @Binding var selectedMarketID: String
    @State private var selectedChoice: UUID? = nil
    @State private var route: Route? = nil
    let markets: [Market] = dummyMarkets
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
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(markets) { market in
                            Button {
                                selectedChoice = market.id
                            } label: {
                                MarketCardView(
                                    market: market,
                                    isSelected: selectedChoice == market.id
                                )
                                .aspectRatio(1, contentMode: .fit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

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
                            selectedMarketID = choice.uuidString
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
        
        
        
    }
}

struct MarketCardView: View {
    let market: Market
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            AsyncImage(url: market.imageName) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 180, height: 180)
                        .frame(maxWidth: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                case .failure:
                    Color.gray.opacity(0.2)
                        .overlay(Image(systemName: "photo").imageScale(.large))
                        .frame(width: 180, height: 180)
                        .frame(maxWidth: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
            .grayscale(isSelected ? 0 : 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("Main") : .clear, lineWidth: 3)
            )
            .cornerRadius(12)
            
            Text(market.marketName)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .frame(maxWidth: .infinity)
                .shadow(radius: 4)
        }
    }
}
