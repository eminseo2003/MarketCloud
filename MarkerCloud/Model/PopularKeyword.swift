//
//  PopularKeyword.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/3/25.
//

import Foundation
import FirebaseFirestore

struct PopularKeyword: Identifiable, Codable, Hashable {
    var id: String { PopularSearchService.normalize(keyword) }

    let keyword: String        // 원래 검색어(표시용)
    let count: Int             // 누적 횟수

    @ServerTimestamp var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case keyword, count, updatedAt
    }
}

