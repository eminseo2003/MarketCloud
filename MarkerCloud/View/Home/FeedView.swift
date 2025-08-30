////
////  ProductDetailView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/16/25.
////
//
//import SwiftUI
//
//struct FeedView: View {
//    let feedId: Int
//    @StateObject private var vm = FeedDetailVM()
//    @StateObject private var likeVM = FeedLikeVM()
//    let currentUserID: Int
//    @State private var isCommentSheetPresented = false
//    
//    var body: some View {
//        VStack {
//            ScrollView {
//                if vm.isLoading {
//                    VStack(spacing: 12) {
//                        ProgressView("불러오는 중…")
//                    }
//                    .frame(maxWidth: .infinity, minHeight: 240)
//                } else if let err = vm.errorMessage {
//                    VStack(spacing: 8) {
//                        Text("불러오기 실패").font(.headline)
//                        Text(err).font(.caption).foregroundStyle(.secondary)
//                        Button("다시 시도") {
//                            Task { await vm.fetch(feedId: feedId) }
//                        }
//                    }
//                    .frame(maxWidth: .infinity, minHeight: 240)
//                } else if let d = vm.detail {
//                    VStack(alignment: .leading, spacing: 16) {
//                        HStack {
//                            if let u = d.storeImageURL {
//                                AsyncImage(url: u) { phase in
//                                    switch phase {
//                                    case .success(let img): img.resizable().scaledToFill()
//                                    default: Circle().fill(Color(uiColor: .systemGray5))
//                                    }
//                                }
//                                .frame(width: 40, height: 40)
//                                .clipShape(Circle())
//                            } else {
//                                Circle()
//                                    .fill(Color(uiColor: .systemGray5))
//                                    .frame(width: 40, height: 40)
//                            }
//                            
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text(d.storeName)
//                                    .font(.headline)
//                                    .foregroundColor(.primary)
//                                Text(formatDate(from: d.createdAt))
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                            Spacer()
//                        }
//                        AsyncImage(url: d.imageURL) { image in
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .aspectRatio(1, contentMode: .fill)
//                                .clipped()
//                        } placeholder: {
//                            Rectangle()
//                                .fill(Color.gray.opacity(0.2))
//                                .aspectRatio(1, contentMode: .fill)
//                        }
//                        
//                        HStack(spacing: 12) {
//                            HStack(spacing: 4) {
//                                Button {
////                                    d.isLiked.toggle()
////                                    d.likeCount += d.isLiked ? 1 : -1
////                                    if d.likeCount < 0 { d.likeCount = 0 }
////                                    
////                                    Task {
////                                        if let dto = await likeVM.toggle(feedId: d.feedId, userId: currentUserID) {
////                                            d.isLiked = dto.isLiked
////                                            d.likeCount = dto.likesCount
////                                        } else {
////                                            d.isLiked.toggle()
////                                            d.likeCount += d.isLiked ? 1 : -1
////                                        }
////                                    }
//                                } label: {
//                                    //Image(systemName: d.isLiked ? "heart.fill" :"heart")
//                                    Image(systemName: "heart")
//                                        .font(.title3)
//                                        //.foregroundColor(d.isLiked ? Color("Main") :.primary)
//                                        .foregroundColor(.primary)
//                                }
//                                Text("\(d.likeCount)")
//                                    .font(.footnote)
//                                    .foregroundColor(.primary)
//                                    .bold()
//                            }
//                            
//                            HStack(spacing: 4) {
//                                Button {
//                                    isCommentSheetPresented = true
//                                } label: {
//                                    Image(systemName: "bubble")
//                                        .font(.title3)
//                                        .foregroundColor(.primary)
//                                }
//                                Text("\(d.reviewCount)")
//                                    .font(.footnote)
//                                    .foregroundColor(.primary)
//                                    .bold()
//                            }
//                            
//                            Spacer()
//                        }
//                        .padding(.vertical, 5)
//                        .padding(.horizontal)
//                        
//                        (
//                            Text(d.title).bold() +
//                            Text(" \(d.content)")
//                        )
//                        .font(.subheadline)
//                        .foregroundColor(.primary)
//                        .padding(.horizontal)
//                        .padding(.bottom, 8)
//                        .sheet(isPresented: $isCommentSheetPresented) {
//                            CommentSheetView(feedId: d.id)
//                                .presentationDetents([.medium])
//                        }
//                        
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                    
//                }
//            }
//            //            Button(action: {
//            //                pushFeed = feed
//            //            }) {
//            //                Text("피드 상세보기")
//            //            }.buttonStyle(FilledCTA())
//            //                .padding()
//        }
//        .navigationTitle(vm.detail?.title ?? "피드")
//        //        .navigationDestination(item: $pushFeed) { feed in
//        //            if feed.promoKind == .store {
//        //
//        //            } else if feed.promoKind == .product {
//        //                ProductDetailView(product: feed)
//        //            } else if feed.promoKind == .event {
//        //                EventDetailView(event: feed)
//        //            }
//        //        }
//    }
//}
