////
////  PopularChartDetailView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/15/25.
////
//
//import SwiftUI
//
//struct RankedStore: Identifiable {
//    let id = UUID()
//    let name: String
//    let follower: Int
//    let imageURL: URL
//}
//
//struct PopularChartDetailView: View {
//    let sectionTitle: String
//    let stores: [RankedStore] = [
//        RankedStore(name: "점포1", follower: 150, imageURL: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?auto=format&fit=crop&w=800&q=80")!),
//        RankedStore(name: "점포2", follower: 26, imageURL: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?auto=format&fit=crop&w=800&q=80")!),
//        RankedStore(name: "점포3", follower: 38, imageURL: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?auto=format&fit=crop&w=800&q=80")!),
//        RankedStore(name: "점포4", follower: 42, imageURL: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?auto=format&fit=crop&w=800&q=80")!),
//        RankedStore(name: "점포5", follower: 51, imageURL: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?auto=format&fit=crop&w=800&q=80")!),
//        RankedStore(name: "용두시장", follower: 850, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "전농시장", follower: 730, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "홍릉시장", follower: 655, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "서울약령시장", follower: 620, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "청량리수산시장", follower: 540, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "용두시장", follower: 8, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "전농시장", follower: 7, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "홍릉시장", follower: 6, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "서울약령시장", follower: 6, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "청량리수산시장", follower: 5, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "용두시장", follower: 8, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "전농시장", follower: 770, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "홍릉시장", follower: 365, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "서울약령시장", follower: 610, imageURL: URL(string: "https://via.placeholder.com/40")!),
//        RankedStore(name: "청량리수산시장", follower: 570, imageURL: URL(string: "https://via.placeholder.com/40")!)
//    ]
//    
//    var top5Stores: [RankedStore] {
//        Array(sortedStores.prefix(5))
//    }
//    
//    var otherStores: [RankedStore] {
//        Array(sortedStores.dropFirst(5))
//    }
//    
//    var sortedStores: [RankedStore] {
//        stores.sorted { $0.follower > $1.follower }
//    }
//    
//    var myStore: RankedStore {
//        stores[3] // 예시: 내 점포는 4번째에 있다고 가정
//    }
//    
//    @State private var visibleCount = 5
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 16) {
//                    // 상위 5개 바 차트
//                    HStack(alignment: .bottom, spacing: 12) {
//                        let maxFollower = top5Stores.first?.follower ?? 1
//                        ForEach(top5Stores, id: \.id) { store in
//                            VStack {
//                                Rectangle()
//                                    .fill(Color("Main"))
//                                    .frame(height: CGFloat(store.follower) / CGFloat(maxFollower) * 150)
//                                    .cornerRadius(6)
//                                Text(store.name)
//                                    .font(.caption)
//                                    .lineLimit(1)
//                                    .truncationMode(.tail)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//                    
//                    // 내 점포 순위 안내
//                    MyStoreRankingView(myStore: myStore, allStores: stores)
//                    
//                    // 6~10위 점포 리스트
//                    VStack(spacing: 12) {
//                        ForEach(otherStores.prefix(visibleCount), id: \.id) { store in
//                            HStack {
//                                Text("\(sortedStores.firstIndex(where: { $0.id == store.id })! + 1). \(store.name)")
//                                    .font(.subheadline)
//                                Spacer()
//                                AsyncImage(url: store.imageURL) { image in
//                                    image.resizable()
//                                        .scaledToFill()
//                                        .frame(width: 32, height: 32)
//                                        .clipShape(Circle())
//                                } placeholder: {
//                                    Circle()
//                                        .fill(Color("Main").opacity(0.3))
//                                        .frame(width: 32, height: 32)
//                                }
//                            }
//                        }
//
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//                    
//                    // 더보기 버튼
//                    if visibleCount < otherStores.count {
//                        Button {
//                            visibleCount += 5
//                        } label: {
//                            Text("더보기")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.bottom)
//                    }
//
//                    Spacer()
//                }
//                .navigationTitle(sectionTitle)
//                .navigationBarTitleDisplayMode(.inline)
//            }
//            
//        }
//    }
//}
//
//struct MyStoreRankingView: View {
//    let myStore: RankedStore
//    let allStores: [RankedStore]
//    
//    private func calculateRankingPercentage(for store: RankedStore, in allStores: [RankedStore]) -> Int? {
//        let sorted = allStores.sorted { $0.follower > $1.follower }
//        guard let rank = sorted.firstIndex(where: { $0.id == store.id }) else {
//            return nil
//        }
//        let percent = Double(rank) / Double(allStores.count) * 100
//        return Int(round(percent))
//    }
//
//    var body: some View {
//        HStack {
//            if let rankPercent = calculateRankingPercentage(for: myStore, in: allStores) {
//                Text("내 점포는 상위 \(100 - rankPercent)%입니다.")
//                    .font(.headline)
//            }
//            Spacer()
//            AsyncImage(url: myStore.imageURL) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 36, height: 36)
//                    .clipShape(Circle())
//            } placeholder: {
//                Circle()
//                    .fill(Color("Main").opacity(0.3))
//                    .frame(width: 36, height: 36)
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(16)
//        .padding(.horizontal)
//    }
//}
