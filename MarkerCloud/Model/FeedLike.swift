//
//  FeedLike.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct FeedLike: Identifiable, Hashable {
    let userId: Int64
    let feedId: Int64
    var createdAt: Date?

    var id: String { "\(userId)-\(feedId)" }
}
