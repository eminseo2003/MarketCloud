//
//  CommentSheetView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI

enum RecommendRoute: Identifiable, Equatable, Hashable {
    case selectComplete(name: String, address: String)

    var id: String {
        switch self {
        case .selectComplete(let name, let address):
            return "selectComplete:\(name)|\(address)"
        }
    }
    var topMarketName: String {
        switch self {
        case .selectComplete(let name, _): return name
        }
    }
    var topMarketAddress: String {
        switch self {
        case .selectComplete(_, let address): return address
        }
    }
}

struct RecommendMarketView: View {
    @StateObject private var vm = MarketRecommendVM()
    @Binding var selectedMarketID: Int
    @State private var route: RecommendRoute? = nil
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
                                optionRowView(title: "평일 낮", selection: $Answer1)
                                optionRowView(title: "평일 저녁", selection: $Answer1)
                                optionRowView(title: "주말 낮", selection: $Answer1)
                                optionRowView(title: "주말 저녁", selection: $Answer1)
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
                                optionRowView(title: "활기 선호", selection: $Answer2)
                                optionRowView(title: "보통", selection: $Answer2)
                                optionRowView(title: "한적 선호", selection: $Answer2)
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
                                optionRowView(title: "자차", selection: $Answer3)
                                optionRowView(title: "자전거", selection: $Answer3)
                                optionRowView(title: "도보", selection: $Answer3)
                                optionRowView(title: "대중교통", selection: $Answer3)
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
                                MultiOptionRow(title: "먹거리 탐방", selections: $Answer4)
                                MultiOptionRow(title: "장보기", selections: $Answer4)
                                MultiOptionRow(title: "구경·산책", selections: $Answer4)
                                MultiOptionRow(title: "데이트", selections: $Answer4)
                            }
                            .padding()
                        }
                        .padding(.vertical)
                    }
                }
                Spacer()
                VStack {
                    Button {
                        Task {
                            await vm.recommend(q1: Answer1 ?? "",
                                               q2: Answer2 ?? "",
                                               q3: Answer3 ?? "",
                                               q4: Answer4)
                            if let dto = vm.result {
                                route = .selectComplete(name: dto.top1Market,
                                                        address: dto.marketAddress)
                            }
                        }
                        
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
                    switch route {
                    case .selectComplete(let name, let address):
                        CompleteRecommendView(
                            selectedMarketID: $selectedMarketID,
                            topMarketName: name,
                                                        topMarketAddress: address
                        )
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
    @Binding var selection: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation(.snappy(duration: 0.12)) {
                    selection = title
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: selection == title ? "checkmark.circle.fill" : "checkmark.circle")
                        .imageScale(.large)
                        .foregroundColor(selection == title ? Color("Main") : .primary.opacity(0.7))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
struct MultiOptionRow: View {
    let title: String
    @Binding var selections: [String]
    var isSelected: Bool { selections.contains(title) }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation(.snappy(duration: 0.12)) {
                    if isSelected {
                        selections.removeAll { $0 == title }
                    } else {
                        selections.append(title)
                    }
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                        .imageScale(.large)
                        .foregroundColor(isSelected ? Color("Main") : .primary.opacity(0.7))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
