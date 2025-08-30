////
////  SettingView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/17/25.
////
//
//import SwiftUI
//
//struct SettingsView: View {
//    @Binding var selectedMarketID: Int
//    @Binding var currentUserID: Int
//    
////    var currentUser: User? {
////            dummyUsers.first { $0.id == currentUserID }
////        }
////    var videoFeeds: [Feed] {
////        dummyFeed.filter { $0.mediaType == .video }
////    }
////
////    var imageFeeds: [Feed] {
////        dummyFeed.filter { $0.mediaType == .image }
////    }
//
//    @State private var route: Route? = nil
//    @State private var showLogoutAlert = false
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(uiColor: .systemGray6)
//                    .ignoresSafeArea()
//                VStack(spacing: 0) {
//                    ScrollView {
//                        VStack(spacing: 15) {
//                            Button(action: {
//                                route = .changeProfile
//                            }) {
//                            
//                                HStack {
//                                    Image(systemName: "person.circle.fill")
//                                        .resizable()
//                                        .frame(width: 60, height: 60)
//                                        .foregroundColor(.gray)
//                                    VStack(alignment: .leading) {
//                                        Text(currentUser?.name ?? "사용자 이름")
//                                            .font(.headline)
//                                            .foregroundColor(.primary.opacity(0.8))
//                                        Text(currentUser?.email ?? "사용자 이메일")
//                                            .font(.subheadline)
//                                            .foregroundColor(.primary.opacity(0.6))
//                                    }
//                                    .padding(.leading, 10)
//                                    Spacer()
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(.primary.opacity(0.8))
//                                        .font(.system(size: 12))
//                                        .padding(.trailing, 8)
//                                }
//                                .padding()
//                                .padding(.horizontal, 15)
//                            }
//                            
//                            
//                            SectionCard {
//                                Button(action: {
//                                    route = .myStore
//                                }) {
//                                    SettingsRow(icon: "storefront.fill", iconTint: .blue, title: "내 점포")
//                                }
//                                Button(action: {
//                                    route = .myProduct
//                                }) {
//                                    SettingsRow(icon: "bag.fill", iconTint: .green, title: "내 상품")
//                                }
//                                Button(action: {
//                                    route = .myEvent
//                                }) {
//                                    SettingsRow(icon: "ticket.fill", iconTint: .red, title: "내 이벤트")
//                                }
//                                
//                                
//                                
//                            }
//                            SectionCard {
//                                Button(action: {
//                                    route = .followingStore
//                                }) {
//                                    SettingsRow(icon: "person.crop.circle.fill.badge.checkmark",
//                                                iconTint: .orange, title: "구독한 계정")
//                                }
//                                Button(action: {
//                                    route = .myLiked
//                                }) {
//                                    SettingsRow(icon: "heart.fill",
//                                                iconTint: Color("Main"), title: "좋아요")
//                                }
//                                Button(action: {
//                                    route = .myReview
//                                }) {
//                                    SettingsRow(icon: "text.bubble.fill",
//                                                iconTint: .green, title: "리뷰")
//                                }
//                            }
//                            Button(action: {
//                                showLogoutAlert = true
//                            }) {
//                                Text("로그아웃")
//                                    .font(.headline)
//                                    .foregroundStyle(.red)
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.vertical, 18)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 18)
//                                            .fill(Color.white)
//                                    )
//                            }
//                            .padding(.horizontal, 20)
//                            Button(action: {}) {
//                                Text("계정 삭제")
//                                    .font(.callout)
//                                    .underline(true, color: Color.gray)
//                                    .foregroundStyle(.gray)
//                                    .padding(.vertical, 8)
//                                    .frame(maxWidth: .infinity)
//                            }
//                            .padding(.bottom, 24)
//                        }
//                        .background(
//                            Color(uiColor: .systemGray6)
//                                
//                        )
//                        .ignoresSafeArea()
//                    }
//                    
//                }
//                
//            }
//            .alert("로그아웃 하시겠어요?", isPresented: $showLogoutAlert) {
//                Button("취소", role: .cancel) { }
//                Button("로그아웃", role: .destructive) {
//                    logout()
//                }
//            } message: {
//                Text("저장된 사용자 정보가 초기화됩니다.")
//            }
//            .navigationDestination(item: $route) { route in
//                if route == .changeProfile {
//                    
//                } else if route == .myStore {
//                    //MyStoreView()
//                } else if route == .myProduct {
//                    //MyProductView()
//                } else if route == .myEvent {
//                    //MyEventView()
//                } else if route == .followingStore {
//                    //MyFollowingView()
//                } else if route == .myLiked {
//                    //MyLikedView(feedList: dummyFeed)
//                } else if route == .myReview {
////                    MyReviewListView(
////                        reviews: sampleReviews
////                    )
//                }
//            }
//        }
//        
//    }
//    private struct SectionCard<Content: View>: View {
//        @ViewBuilder var content: Content
//        var body: some View {
//            VStack(spacing: 0) { content }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 16)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(
//                    RoundedRectangle(cornerRadius: 18, style: .continuous)
//                        .fill(Color.white)
//                )
//                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
//                .padding(.horizontal, 20)
//        }
//    }
//    private struct SettingsRow: View {
//        let icon: String
//        let iconTint: Color
//        let title: String
//        var body: some View {
//            HStack(spacing: 12) {
//                Image(systemName: icon)
//                    .font(.system(size: 20, weight: .semibold))
//                    .foregroundStyle(iconTint)
//                    .frame(width: 36, height: 36, alignment: .center)
//                
//                Text(title)
//                    .font(.body)
//                    .foregroundStyle(.black)
//                
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .font(.footnote)
//                    .foregroundStyle(.tertiary)
//            }
//            .padding(.vertical, 10)
//            .padding(.horizontal, 10)
//        }
//    }
//    private func logout() {
//        currentUserID = -1
//        selectedMarketID = -1
//        route = nil
//    }
//}
