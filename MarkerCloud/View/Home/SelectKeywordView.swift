//
//  SelectKeywordView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/29/25.
//

import SwiftUI

import SwiftUI

struct SelectKeywordView: View {
    let keywords: [String] = ["장보기", "먹거리 탐방", "데이트"]

    @State private var selectedIndex: Int? = nil
    @State private var isShuffling = false
    @State private var showSparkle = false

    var body: some View {
        VStack(spacing: 20) {
            // 헤더
            HStack {
                Text("오늘의 행운 키워드")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.top, 4)

            Text("하나를 고르거나, 랜덤 뽑기로 운명을 맡겨보세요!")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(displayedIndices, id: \.self) { i in
                    Button {
                        guard !isShuffling else { return }
                        select(i)
                    } label: {
                        keywordChip(
                            text: keywords[i],
                            isSelected: selectedIndex == i,
                            isShuffling: isShuffling
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isShuffling)
                }
            }
            .padding(.top, 6)

            Spacer(minLength: 8)

            // 액션 버튼들
            HStack(spacing: 12) {
                Button {
                    Task { await spinPick() }
                } label: {
                    Label("랜덤 뽑기", systemImage: "dice.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RandomCTA())
                .disabled(isShuffling)

                Button {
                    confirm()
                } label: {
                    Label("이 키워드로", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FilledCTA())
                .disabled(selectedIndex == nil || isShuffling)
            }

            // 선택 안내
            if let idx = selectedIndex {
                Text("선택됨: \(keywords[idx])")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .scale))
            }
        }
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

    // 표시할 인덱스(키워드가 3개 미만이어도 안전)
    private var displayedIndices: [Int] {
        Array(keywords.indices.prefix(3))
    }


    private func select(_ i: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedIndex = i
    }

    private func confirm() {
        guard let i = selectedIndex else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.easeInOut(duration: 0.35)) { showSparkle = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation { showSparkle = false }
            //onConfirm(keywords[i])
        }
    }

    /// 슬롯머신처럼 빠르게 순환 후 무작위 선택
    private func spinPick() async {
        guard !displayedIndices.isEmpty else { return }
        isShuffling = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 점점 느려지는 순환
        var delay: Double = 0.08
        let rounds = 10  // 순환 횟수
        for step in 0..<(rounds + Int.random(in: 3...6)) {
            let i = displayedIndices[step % displayedIndices.count]
            await MainActor.run { selectedIndex = i }
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            delay *= 1.15
        }

        // 최종 랜덤 고정
        let final = displayedIndices.randomElement()!
        await MainActor.run {
            selectedIndex = final
            isShuffling = false
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - UI parts

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

struct RandomCTA: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.bold())
            .foregroundStyle(.primary)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(uiColor: .secondarySystemBackground)))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

