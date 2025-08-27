//
//  CommentSheetView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

struct Quest: Identifiable {
    let id = UUID()
    let title: String
    let quest1: String
    let quest2: String
}
struct RecommendMarketView: View {
    @Binding var selectedMarketID: String
    @State private var route: Route? = nil
    @State var Answer1: String? = nil
    @State var Answer2: String? = nil
    @State var Answer3: String? = nil
    @State var Answer4: [String] = []
    var allAnswered: Bool {
        guard
            let a1 = Answer1?.trimmingCharacters(in: .whitespacesAndNewlines), !a1.isEmpty,
            let a2 = Answer2?.trimmingCharacters(in: .whitespacesAndNewlines), !a2.isEmpty,
            let a3 = Answer3?.trimmingCharacters(in: .whitespacesAndNewlines), !a3.isEmpty
        else { return false }
        // 배열이 비어있지 않고, 최소 하나는 공백이 아닌 항목이어야 함
        return Answer4.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section() {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("질문 1. 주로 언제 시장에 가시나요?")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 16) {
                                optionRowView(title: "평일 낮")
                                optionRowView(title: "평일 저녁")
                                optionRowView(title: "주말 낮")
                                optionRowView(title: "주말 저녁")
                            }
                            .padding()
                        }
                        .padding(.vertical)
                    }
                    Section() {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("질문 2. 사람 많은 활기찬 시장 vs 한적한 시장, 어떤 쪽이 좋을까요?")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 16) {
                                optionRowView(title: "활기 선호")
                                optionRowView(title: "보통")
                                optionRowView(title: "한적 선호")
                            }
                            .padding()
                        }
                        .padding(.vertical)
                    }
                    Section() {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("질문 3. 주 이용수단을 골라주세요.")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 16) {
                                optionRowView(title: "자차")
                                optionRowView(title: "자전거")
                                optionRowView(title: "도보")
                                optionRowView(title: "대중교통")
                            }
                            .padding()
                        }
                        .padding(.vertical)
                    }
                    Section() {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("질문 4. 방문 목적을 골라주세요.(다중 선택 가능)")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 16) {
                                optionRowView(title: "먹거리 탐방")
                                optionRowView(title: "장보기")
                                optionRowView(title: "구경·산책")
                                optionRowView(title: "데이트")
                            }
                            .padding()
                        }
                        .padding(.vertical)
                    }
                }
                Spacer()
                VStack {
                    Button {
                        route = .selectComplete
                    } label: {
                        Text("완료")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(allAnswered ? Color("Main") : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .disabled(!allAnswered)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGroupedBackground))
                .navigationDestination(item: $route) { route in
                    if route == .selectComplete {
                        //CompleteRecommendView(selectedMarketID: $selectedMarketID)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("시장추천받기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct optionRowView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation(.snappy(duration: 0.12)) {
                    //selectedIndex = index
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .imageScale(.large)
                        .foregroundColor(Color("Main"))
//                    Image(systemName: selectedIndex == index ? "checkmark.circle.fill" : "checkmark.circle")
//                        .imageScale(.large)
//                        .foregroundColor(selectedIndex == index ? Color("Main") : .primary.opacity(0.7))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
