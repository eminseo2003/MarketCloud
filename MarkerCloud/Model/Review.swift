//
//  Review.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import Foundation

struct Review: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var userId: String
    var feedId: String

    var content: String
    var imageURL: URL?
    var rating: Double
    var createdAt: Date

    var serverId: Int64?                    // reviewid
    var serverUserId: Int64?                // userid
    var serverFeedId: Int64?                // feedid
}
