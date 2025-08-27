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
    let quests: [Quest] = [
        Quest(title: "질문은 저희가 결정할 시장에 따라 바꾸도록 할게요", quest1: "답변 하나", quest2: "답변 둘"),
        Quest(title: "질문은 저희가 결정할 시장에 따라 바꾸도록 할게요", quest1: "답변 하나", quest2: "답변 둘")
    ]
    @State private var route: Route? = nil
    @State private var selections: [UUID: Int] = [:]
    var allAnswered: Bool {
        quests.allSatisfy { selections[$0.id] != nil }
    }
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    ForEach(quests) { quest in
                        Section() {
                            QuestCardView(
                                quest: quest,
                                selectedIndex: Binding(
                                    get: { selections[quest.id] },
                                    set: { selections[quest.id] = $0 }
                                )
                            )
                        }
                        
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
struct QuestCardView: View {
    let quest: Quest
    @Binding var selectedIndex: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(quest.title)
                .font(.headline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 16) {
                optionRow(title: quest.quest1, index: 0)
                optionRow(title: quest.quest2, index: 1)
            }
            .padding()
        }
        .padding(.vertical)
    }
    @ViewBuilder
    private func optionRow(title: String, index: Int) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.12)) {
                selectedIndex = index
            }
        } label: {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: selectedIndex == index ? "checkmark.circle.fill" : "checkmark.circle")
                    .imageScale(.large)
                    .foregroundColor(selectedIndex == index ? Color("Main") : .primary.opacity(0.7))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
