//
//  ProductDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/18/25.
//

import SwiftUI
import PhotosUI

enum ProductRoute: Hashable, Identifiable {
    case postImageRoute
    case postMemoRoute
    case productNameRoute
    case postReviewRoute
    var id: Self { self }
}
struct ProductDetailView: View {
    let product: Feed
    
    @State private var productRoute: ProductRoute? = nil
    private let productPromotion = Promotion(name: "상품", imageName: "loginBackground")
    @State private var pushPromotion: Promotion? = nil
    @State private var route: Route? = nil
    @State private var isImagesExpanded = false
    @State private var isScriptExpanded = false
    @State private var isInfoExpanded = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        VStack {
                            LazyVGrid(columns: [GridItem()], spacing: 8) {
                                LargeReviewImage(url: product.mediaUrl)
                            }
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))


                        VStack(spacing: 1) {
                            Button(action: {
                                productRoute = .productNameRoute
                            }) {
                                RowButton(title: "상품 이름",
                                          value: product.title.isEmpty ? " " : product.title,
                                          icon: "chevron.right")
                            }
                            Button { productRoute = .postMemoRoute } label: {
                                    RowButton(title: "상품 내용",
                                              value: clean(product.body),
                                              icon: "chevron.right")
                                }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 1) {
                            Button {
                                withAnimation(.easeInOut) { isInfoExpanded.toggle() }
                            } label: {
                                RowButton(title: "홍보글 생성에 사용된 정보",
                                          value: " ",
                                          icon: isInfoExpanded ? "chevron.down" : "chevron.right")
                            }
                            if isInfoExpanded {
                                RowButton(title: "카테고리",
                                          value: product.product?.category?.displayName ?? " ", icon: nil)
                                Button {
                                    withAnimation(.easeInOut) { isScriptExpanded.toggle() }
                                } label: {
                                    RowButton(title: "상품 설명",
                                              value: isScriptExpanded ? " " : clean(product.body),
                                              icon: isScriptExpanded ? "chevron.down" : "chevron.right")
                                }
                                if isScriptExpanded {
                                    SubRowButton(value: clean(product.body))
                                    
                                }
                                Button {
                                    withAnimation(.easeInOut) { isImagesExpanded.toggle() }
                                } label: {
                                    RowButton(title: "사용된 이미지",
                                              value: "",
                                              icon: isImagesExpanded ? "chevron.down" : "chevron.right")
                                }
                                if isImagesExpanded, product.promoKind == .product {
                                    if let url = product.product?.imgUrl {
                                        RemoteThumb(url: url)
                                            .padding(.top, 6)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                    
                                }

                            }
                            
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) {
                        VStack(spacing: 1) {
                            Button {
                                productRoute = .postReviewRoute
                            } label: {
                                RowButton(title: "리뷰 보러가기",
                                          value: " ",
                                          icon: "chevron.right")
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    .padding(.horizontal, 16)

                    
                }
                .padding(.top, 8)
            }
            Button {
                pushPromotion = productPromotion
            } label: {
                Text("상품 홍보 생성하기")
            }.buttonStyle(FilledCTA())
                .padding()
            .padding(.vertical, 8)
        }
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        .navigationTitle("\(product.title) 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
        }
        .navigationDestination(item: $productRoute) { r in
            if productRoute == .productNameRoute {
                ChangeproductName(name: product.title)
            } else if productRoute == .postMemoRoute {
                ChangeproductMemo(productMemo: product.body)
            } else if productRoute == .postReviewRoute {
                ReviewListView(reviews: product.reviews, feed: product)
            }
        }
        .navigationDestination(item: $pushPromotion) { promo in
            PromotionMethodSelectView(promotion: promo)
        }
    }
    private func clean(_ s: String?) -> String {
        let t = s?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return t.isEmpty ? " " : t
    }
}

private struct RowButton: View {
    let title: String
    let value: String
    let icon: String?
    private let iconWidth: CGFloat = 12
    
    var body: some View {
        HStack {
            Text(title).font(.body).bold().foregroundColor(.primary)
            Spacer(minLength: 12)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(1)
            if let icon {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .frame(width: iconWidth, alignment: .trailing)
            } else {
                Color.clear.frame(width: iconWidth)
            }
            
        }
        .frame(minHeight: 46)
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }
}
private struct SubRowButton: View {
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(value).font(.body).foregroundColor(.secondary)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}
//private struct ProductImageGrid: View {
//    let urls: [URL]
//    private let columns = [GridItem(.adaptive(minimum: 90), spacing: 8)]
//
//    var body: some View {
//        HStack {
//            Image(systemName: "arrow.turn.down.right")
//                .frame(width: 18, alignment: .leading)
//            LazyVGrid(columns: columns, spacing: 8) {
//                ForEach(urls, id: \.self) { url in
//                    RemoteThumb(url: url)
//                }
//            }.frame(width: 262, alignment: .leading)
//            Spacer()
//        }
//        .frame(minHeight: 44)
//        .contentShape(Rectangle())
//        .padding(.vertical, 4)
//        
//    }
//}
