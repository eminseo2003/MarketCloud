//
//  FeedLike.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation
import FirebaseFirestore

struct FeedLike: Identifiable, Codable, Hashable {
    let userId: String
    let feedId: String

    @ServerTimestamp var createdAt: Date?

    var id: String { "\(feedId)-\(userId)" }

    enum CodingKeys: String, CodingKey {
        case userId, feedId, createdAt
    }

    init(userId: String, feedId: String, createdAt: Date? = nil) {
        self.userId = userId
        self.feedId = feedId
        self.createdAt = createdAt
    }
}

extension FeedLike {
    static var collection: CollectionReference {
        Firestore.firestore().collection("feedLikes")
    }

    var docRef: DocumentReference {
        Self.collection.document(id)
    }

    func toCreateDict() -> [String: Any] {
        [
            "userId": userId,
            "feedId": feedId,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}

