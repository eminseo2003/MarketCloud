//
//  MarketListVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

private extension String {
    var normalizedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

@MainActor
final class MarketListVM: ObservableObject {
    // 원본 데이터 (읽기 전용 공개)
    @Published private(set) var markets: [Market] = []
    // 검색/상태
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Public API

    /// 정적 배열을 메모리로 적재 (네트워크 없음)
    func load() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        markets = traditionalMarkets
    }

    /// 검색 결과 (시장명/주소에 매칭)
    var filteredMarkets: [Market] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return markets }
        let nq = q.normalizedForSearch
        return markets.filter { m in
            m.marketName.normalizedForSearch.contains(nq) ||
            m.address.normalizedForSearch.contains(nq)
        }
    }

    // MARK: - Helpers (기존 사용처 호환)

    func assetName(forMarketName name: String) -> String {
        markets.first { $0.marketName == name }?.marketImg ?? "market_default"
    }

    func marketCode(forMarketName name: String) -> Int {
        markets.first { $0.marketName == name }?.id ?? 0
    }

    func market(byID id: Int) -> Market? {
        markets.first { $0.id == id }
    }
}
