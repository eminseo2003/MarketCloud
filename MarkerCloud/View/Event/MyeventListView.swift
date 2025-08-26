//
//  MyeventListView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

private extension String {
    var normalizedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
struct MyeventListView: View {
    let eventList: [Feed]
    @State private var selectedEvent: Feed? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @StateObject private var keyboard = KeyboardResponder()
    private let eventPromotion = Promotion(name: "이벤트", imageName: "loginBackground")
    @State private var pushPromotion: Promotion? = nil
    
    private var filteredEvents: [Feed] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return eventList }
        let nq = q.normalizedForSearch
        
        return eventList.filter { p in
            p.title.normalizedForSearch.contains(nq) ||
            p.title.normalizedForSearch.contains(nq)
        }
    }
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("Main"))
                    .bold(true)
                TextField("검색어를 입력하세요", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTextFieldFocused)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        isTextFieldFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("완료") { isTextFieldFocused = false }
//                }
//            }
            ScrollView {
                if filteredEvents.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("검색 결과가 없어요")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                        ForEach(filteredEvents) { event in
                            EventCard(event: event, selectedEvent: $selectedEvent)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.snappy, value: filteredEvents.count)
                }
                
            }
            Button(action: {
                pushPromotion = eventPromotion
            }) {
                Text("이벤트 등록하기")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .font(.body)
                    .padding()
                    .background(Color("Main"))
                    .cornerRadius(12)
            }.padding(.horizontal)
        }
        .navigationDestination(item: $selectedEvent) { event in
            EventPostView(feed: event)
                .navigationTitle(event.title)
        }
        .navigationDestination(item: $pushPromotion) { promo in
            PromotionMethodSelectView(promotion: promo)
        }
        
    }
}
