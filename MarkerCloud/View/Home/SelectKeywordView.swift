//
//  SelectKeywordView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/29/25.
//

import SwiftUI

struct SelectKeywordView: View {
    @StateObject private var keywordVM = KeywordVM()

    @State private var selectedKeyword: String? = nil

    @State private var selectedIndex: Int? = nil
    @State private var isShuffling = false
    @State private var showSparkle = false

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

            // 본문
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
                                    isSelected: selectedIndex == i,
                                    isShuffling: isShuffling
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isShuffling)
                        }
                    }
                    .padding(.top, 6)
                }
            }

            Spacer(minLength: 8)

            HStack(spacing: 12) {
                Button {
                    Task { await spinPick() }
                } label: {
                    Label("랜덤 뽑기", systemImage: "dice.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlineCTA())
                .disabled(isShuffling || displayedKeywords.isEmpty)

                Button {
                    
                } label: {
                    Label("이 키워드로", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FilledCTA())
                .disabled(selectedIndex == nil || isShuffling)
            }
        }
        .task { await keywordVM.fetch() }
        .padding(20)
        .background(
            ZStack {
                Color(uiColor: .systemBackground)
                if showSparkle {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .opacity(0.18)
                        .scaleEffect(1.3)
                        .transition(.opacity)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedIndex)
        .animation(.easeInOut, value: isShuffling)
    }

    private var displayedKeywords: [String] {
        Array(keywordVM.keywords.prefix(3))
    }

//    private func select(_ i: Int) {
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        selectedIndex = i
//    }
//
//    private func confirm() {
//        guard let i = selectedIndex, displayedKeywords.indices.contains(i) else { return }
//        let chosen = displayedKeywords[i]
//        UINotificationFeedbackGenerator().notificationOccurred(.success)
//        withAnimation(.easeInOut(duration: 0.35)) { showSparkle = true }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//            withAnimation { showSparkle = false }
//            onConfirm?(chosen)
//        }
//    }

    private func spinPick() async {
        guard !displayedKeywords.isEmpty else { return }
        isShuffling = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        var delay: Double = 0.08
        let rounds = 10
        for step in 0..<(rounds + Int.random(in: 3...6)) {
            let i = step % displayedKeywords.count
            await MainActor.run { selectedIndex = i }
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            delay *= 1.15
        }

        await MainActor.run {
            selectedIndex = Int.random(in: 0..<displayedKeywords.count)
            isShuffling = false
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }


    private func keywordChip(text: String, isSelected: Bool, isShuffling: Bool) -> some View {
        HStack {
            Text(text)
                .font(.headline)
                .foregroundStyle(isSelected ? .white : .primary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            Group {
                if isSelected {
                    LinearGradient(
                        colors: [Color("Main"), Color("Main").opacity(0.85)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                } else {
                    Color(uiColor: .secondarySystemBackground)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color.clear : Color.black.opacity(0.06), lineWidth: 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .rotation3DEffect(.degrees(isShuffling ? 7 : 0), axis: (x: 0, y: 1, z: 0))
        .shadow(color: isSelected ? Color("Main").opacity(0.25) : .clear, radius: 10, x: 0, y: 6)
        .contentShape(Rectangle())
    }
}
