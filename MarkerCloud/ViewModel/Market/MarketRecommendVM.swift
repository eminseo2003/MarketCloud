//
//  MarketRecommendVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import Combine

@MainActor
final class MarketRecommendVM: ObservableObject {
    @Published var results: [Market] = []
    @Published var errorMessage: String?

    func run(q1: String, q2: String, q3: String, q4: String, topK: Int = 3) {
        errorMessage = nil
        let recos = MarketRecommender.shared.recommend(q1: q1, q2: q2, q3: q3, q4: q4, topK: topK)
        if recos.isEmpty { errorMessage = "조건에 맞는 추천을 찾지 못했어요." }
        results = recos
    }
}


