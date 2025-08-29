//
//  SelectKeywordView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/29/25.
//

import SwiftUI

struct SelectKeywordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var keywordVM = KeywordVM()
    @StateObject private var recommendVM = KeywordMarketVM()
    @StateObject private var vm = MarketListVM()

    @State private var selectedKeyword: String? = nil

    @State private var isShuffling = false
    @Binding var selectedMarketID: Int
    
    private var hasRecommendation: Bool {
        recommendVM.result != nil
    }

    private func resetRecommendation() {
        selectedKeyword = nil
        recommendVM.result = nil
        isShuffling = false
        Task { await keywordVM.fetch() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("오늘의 행운 키워드").font(.title2.bold())
                Spacer()
            }
            .padding(.top, 4)

            Text("하나를 고르거나, 랜덤 뽑기로 운명을 맡겨보세요!")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                
                Group {
                    if keywordVM.isLoading {
                        ProgressView().padding(.top, 12)
                    } else if let err = keywordVM.errorMessage {
                        VStack(spacing: 8) {
                            Text("불러오기 실패").font(.headline)
                            Text(err).font(.caption).foregroundStyle(.secondary)
                            Button("다시 시도") { Task { await keywordVM.fetch() } }
                        }
                    } else if displayedKeywords.isEmpty {
                        Text("표시할 키워드가 없습니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(displayedKeywords.enumerated()), id: \.offset) { i, word in
                                Button {
                                    selectedKeyword = word
                                } label: {
                                    keywordChip(
                                        text: word,
                                        isSelected: selectedKeyword == word
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isShuffling)
                            }
                            Spacer()
                            Group {
                                    if recommendVM.isLoading {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                            Text("생성중...")
                                        }
                                        .padding(.vertical, 12)
                                    } else if let err = recommendVM.errorMessage {
                                        VStack(spacing: 6) {
                                            Text("추천 실패").font(.subheadline).bold()
                                            Text(err).font(.caption).foregroundStyle(.secondary)
                                            Button("다시 시도") {
                                                guard let k = selectedKeyword ?? displayedKeywords.first else { return }
                                                Task { await recommendVM.fetch(keywordName: k) }
                                            }
                                            .font(.caption)
                                        }
                                        .padding(.vertical, 8)
                                    } else if let r = recommendVM.result {
                                        VStack(alignment: .center, spacing: 16) {
                                            VStack(alignment: .leading, spacing: 24) {
                                                VStack {
                                                    LazyVGrid(columns: [GridItem()], spacing: 8) {
                                                        MarketRecommandImage(assetName: vm.assetName(forMarketName: r.marketName)) //얘가 항상 defaultimage로 들어가고 있어
                                                    }
                                                    
                                                }
                                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("오늘의 시장 추천: \(r.marketName)")
                                                        .font(.title3).bold()
                                                        .foregroundStyle(.primary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    
                                                    Text("\(r.description)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                            .padding(.vertical, 16)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(Color(UIColor.systemBackground))
                                            )
                                        }
                                    }
                                }
                        }
                    }
                }

                
            }
            .scrollIndicators(.hidden)
            Spacer(minLength: 8)

            HStack(spacing: 12) {
                if hasRecommendation {
                    Button {
                                resetRecommendation()
                        
                            } label: {
                                Label("다시 뽑기", systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(OutlineCTA())

                            Button {
                                guard let r = recommendVM.result else { return }
                                let code = vm.marketCode(forMarketName: r.marketName)
                                if code != 0 {
                                    selectedMarketID = code
                                    dismiss()
                                } else {
                                    
                                }
                            } label: {
                                Label("추천 시장 둘러보기", systemImage: "location.viewfinder")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FilledCTA())
                } else {
                    Button {
                        Task { await spinPick() }
                    } label: {
                        Label("랜덤 뽑기", systemImage: "dice.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OutlineCTA())
                    .disabled(isShuffling || displayedKeywords.isEmpty)

                    Button {
                        guard let keyword = selectedKeyword else { return }
                        recommendVM.result = nil
                        Task {
                            await recommendVM.fetch(keywordName: keyword)
                            if let r = recommendVM.result {
                                print("추천 시장:", r.marketName)
                                // selectedMarketID = r.marketId  // 필요 시 여기서 라우팅/저장
                            }
                        }
                    } label: {
                        Label("이 키워드로", systemImage: "wand.and.stars")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FilledCTA())
                    .disabled(selectedKeyword == nil || isShuffling)
                }
                
            }
        }
        .task {
            await keywordVM.fetch()
            await vm.fetch()
        }
        .padding(20)
        .background(
            ZStack {
                Color(uiColor: .systemBackground)
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var displayedKeywords: [String] {
        Array(keywordVM.keywords.prefix(3))
    }

    private func spinPick() async {
            guard !displayedKeywords.isEmpty else { return }
            isShuffling = true
            var delay: Double = 0.08
            let rounds = 10
            for step in 0..<(rounds + Int.random(in: 3...6)) {
                let w = displayedKeywords[step % displayedKeywords.count]
                await MainActor.run { selectedKeyword = w }
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                delay *= 1.15
            }
            await MainActor.run {
                selectedKeyword = displayedKeywords.randomElement()
                isShuffling = false
            }
        }


    private func keywordChip(text: String, isSelected: Bool) -> some View {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                ? AnyShapeStyle(LinearGradient(
                    colors: [Color("Main"), Color("Main").opacity(0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                : AnyShapeStyle(Color(uiColor: .secondarySystemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? .clear : .black.opacity(0.06), lineWidth: 1)
            )
        }
}
