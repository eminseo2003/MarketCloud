////
////  MyproductListView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/18/25.
////
//
//import SwiftUI
//
//private extension String {
//    var normalizedForSearch: String {
//        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
//    }
//}
//struct MyproductListView: View {
//    let productList: [Feed]
//    @State private var selectedProduct: Feed? = nil
//    @FocusState private var isTextFieldFocused: Bool
//    @State private var searchText: String = ""
//    private let productPromotion = Promotion(name: "상품", imageName: "loginBackground")
//    @State private var pushPromotion: Promotion? = nil
//    
//    private var filteredProducts: [Feed] {
//        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !q.isEmpty else { return productList }
//        let nq = q.normalizedForSearch
//        
//        return productList.filter { p in
//            p.title.normalizedForSearch.contains(nq) ||
//            p.body.normalizedForSearch.contains(nq)
//        }
//    }
//    var body: some View {
//        VStack(spacing: 16) {
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(Color("Main"))
//                    .bold(true)
//                TextField("검색어를 입력하세요", text: $searchText)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .focused($isTextFieldFocused)
//                if !searchText.isEmpty {
//                    Button {
//                        searchText = ""
//                        isTextFieldFocused = false
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundStyle(.secondary)
//                    }
//                }
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .padding(.horizontal)
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("완료") { hideKeyboard() }
//                }
//            }
//            ScrollView {
//                if filteredProducts.isEmpty {
//                    VStack(spacing: 8) {
//                        Image(systemName: "magnifyingglass")
//                            .font(.title2)
//                            .foregroundStyle(.secondary)
//                        Text("검색 결과가 없어요")
//                            .foregroundStyle(.secondary)
//                            .font(.subheadline)
//                    }
//                    .frame(maxWidth: .infinity, minHeight: 200)
//                } else {
//                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
//                        ForEach(filteredProducts) { product in
//                            FeedCard(feed: product, selectedFeed: $selectedProduct)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .animation(.snappy, value: filteredProducts.count)
//                }
//                
//            }
//            Button(action: {
//                pushPromotion = productPromotion
//            }) {
//                Text("상품 등록하기")
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .font(.body)
//                    .padding()
//                    .background(Color("Main"))
//                    .cornerRadius(12)
//            }.padding(.horizontal)
//        }
//        .navigationDestination(item: $selectedProduct) { product in
//            FeedView(feed: product)
//                .navigationTitle(product.title)
//        }
//        .navigationDestination(item: $pushPromotion) { promo in
//            PromotionMethodSelectView(promotion: promo)
//        }
//        
//    }
//    private func hideKeyboard() {
//        isTextFieldFocused = false
//    }
//}
