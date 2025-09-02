//
//  ProductDetailView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/18/25.
//

import SwiftUI
import PhotosUI

enum StoreFeedRoute: Hashable, Identifiable {
    case feedNameRoute
    case feedMemoRoute
    case feedReviewRoute
    var id: Self { self }
}
struct StoreFeedDetail: View {
    let feedId: String
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    @StateObject private var feedVm = FeedVM()
    
    @State private var feedRoute: StoreFeedRoute? = nil
    private let productPromotion = Promotion(name: "점포", imageName: "loginBackground")
    @State private var pushPromotion: Promotion? = nil
    @State private var route: Route? = nil
    @State private var isImagesExpanded = false
    @State private var isScriptExpanded = false
    @State private var isInfoExpanded = false

    var body: some View {
        VStack {
            ScrollView {
                if feedVm.isLoading {
                    ProgressView("불러오는 중…").padding(.top, 24)
                } else if let err = feedVm.errorMessage {
                    VStack(spacing: 8) {
                        Text("불러오기 실패").font(.headline)
                        Text(err).foregroundColor(.secondary).font(.caption)
                        Button("다시 시도") { Task { await feedVm.load(feedId: feedId) } }
                    }
                    .padding(.vertical, 24)
                } else {
                    VStack(spacing: 16) {
                        VStack(spacing: 16) {
                            VStack {
                                LazyVGrid(columns: [GridItem()], spacing: 8) {
                                    if let url = feedVm.mediaUrl {
                                        LargeReviewImage(url: url)
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 300)
                                    }
                                    
                                }
                                
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))


                            VStack(spacing: 1) {
                                Button(action: {
                                    feedRoute = .feedNameRoute
                                }) {
                                    RowButton(title: "상품 이름",
                                              value: feedVm.title ?? " ",
                                              icon: "chevron.right")
                                }
                                Button { feedRoute = .feedMemoRoute } label: {
                                        RowButton(title: "상품 내용",
                                                  value: clean(feedVm.body ?? ""),
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
                                    Button {
                                        withAnimation(.easeInOut) { isScriptExpanded.toggle() }
                                    } label: {
                                        RowButton(title: "상품 설명",
                                                  value: isScriptExpanded ? " " : clean(feedVm.storeInfo?.description ?? ""),
                                                  icon: isScriptExpanded ? "chevron.down" : "chevron.right")
                                    }
                                    if isScriptExpanded {
                                        SubRowButton(value: clean(feedVm.storeInfo?.description ?? " "))
                                        
                                    }
                                    Button {
                                        withAnimation(.easeInOut) { isImagesExpanded.toggle() }
                                    } label: {
                                        RowButton(title: "사용된 이미지",
                                                  value: "",
                                                  icon: isImagesExpanded ? "chevron.down" : "chevron.right")
                                    }
                                    if isImagesExpanded {
                                        if let promoKind = feedVm.promoKind {
                                            if promoKind == "store" {
                                                if let url = feedVm.storeInfo?.imgUrl {
                                                    RemoteThumb(url: url)
                                                        .padding(.top, 6)
                                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                                }
                                            }
                                            
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
                                    feedRoute = .feedReviewRoute
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
        .navigationTitle("\(feedVm.title ?? "") 정보")
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
        .navigationDestination(item: $feedRoute) { r in
            if feedRoute == .feedNameRoute {
                //ChangeproductName(name: product.title)
            } else if feedRoute == .feedMemoRoute {
                //ChangeproductMemo(productMemo: product.body)
            } else if feedRoute == .feedReviewRoute {
                //ReviewListView(reviews: product.reviews, feed: product)
            }
        }
        .navigationDestination(item: $pushPromotion) { promo in
            PromotionMethodSelectView(promotion: promo, appUser: appUser, selectedMarketID: $selectedMarketID)
        }
        .task {
            await feedVm.load(feedId: feedId)
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
