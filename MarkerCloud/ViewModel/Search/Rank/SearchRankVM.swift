//
//  SearchRankVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

@MainActor
final class SearchRankVM: ObservableObject {
    @Published var rankings: [String] = []

    func fetchTop5() async {
        let top = await PopularSearchService.fetchTop5()
        let arr = top.map { $0.keyword }
        print("[SearchRankVM] fetchTop5 ->", arr)
        self.rankings = arr
    }

    func bumpAndRefresh(keyword: String) async {
        try? await PopularSearchService.increment(keyword: keyword)
        await fetchTop5()
    }
}
