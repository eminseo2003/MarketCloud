////
////  IfHasStoreView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/17/25.
////
//
//import SwiftUI
//
//struct NoStoreView: View {
//    @StateObject private var storeDetail = StoreDetail()
//        @State private var route: Route? = nil
//    let ismypage: Bool
//        var body: some View {
//            NavigationStack {
//                VStack(spacing: 0) {
//                    if ismypage == false {
//                        HStack {
//                            Image("screentoplogo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 40, height: 40)
//                            Text("Market Cloud")
//                                .foregroundColor(.black)
//                                .frame(height: 30)
//                                .font(.title)
//                                .bold(true)
//                            Spacer()
//                        }
//                        .padding(.horizontal)
//                        .background(Color(uiColor: .systemGray6))
//                    }
//                    
//                    ZStack {
//                        VStack(spacing: 12) {
//                            Image(systemName: "storefront")
//                                .font(.system(size: 40))
//                                .foregroundStyle(.secondary)
//                            Text("등록된 점포가 없습니다.")
//                                .font(.headline)
//                                .foregroundStyle(.secondary)
//                        }
//                        VStack(spacing: 12) {
//                            Spacer()
//                            Button(action: {
//                                route = .firstStoreCreate
//                            }) {
//                                Text("점포 등록하기")
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.white)
//                                    .frame(maxWidth: .infinity)
//                                    .font(.body)
//                                    .padding()
//                                    .background(Color("Main"))
//                                    .cornerRadius(12)
//                            }
//                        }
//                    }
//                    .padding()
//                    
//                }
//                
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color(uiColor: .systemGray6).ignoresSafeArea())
//                .navigationDestination(item: $route) { route in
//                    if route == .firstStoreCreate {
//                        FirstStoreCreateView(storeDetail: storeDetail)
//                    }
//                }
//            }
//            
//        }
//    }
//
