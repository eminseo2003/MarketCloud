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
    
    @FocusState private var isTextFieldFocused: Bool
    
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
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("Main"))
                        .bold(true)
                    TextField("시장명/주소를 입력하세요", text: $vm.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($isTextFieldFocused)
                    if !vm.searchText.isEmpty {
                        Button {
                            vm.searchText = ""
                            isTextFieldFocused = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(vm.filteredMarkets) { market in
                            Button {
                                selectedChoice = market.id
                            } label: {
                                MarketCardView(
                                    name: market.marketName,
                                    assetName: market.marketImg,
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
        .onAppear { vm.load() }
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
                        .stroke(isSelected ? Color(.gray) : .clear, lineWidth: 5)
                )
                .cornerRadius(12)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.0), .black.opacity(0.3)]),
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
