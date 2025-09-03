//
//  Review.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable, Hashable {
    let userId: String
    let feedId: String

    @ServerTimestamp var createdAt: Date?

    var id: String { "\(feedId)-\(userId)" }

    var content: String
    var imageURL: URL?
    var rating: Double

}
