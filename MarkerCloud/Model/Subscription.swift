//
//  Subscription.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation
import FirebaseFirestore

struct Subscription: Codable, Hashable, Identifiable {
    var userId: String
    var storeId: String

    @ServerTimestamp var createdAt: Date?

    var id: String { "\(storeId)-\(userId)" }

    enum CodingKeys: String, CodingKey {
        case userId, storeId, createdAt
    }

    init(userId: String, storeId: String, createdAt: Date? = nil) {
        self.userId = userId
        self.storeId = storeId
        self.createdAt = createdAt
    }
}
extension Subscription {
    static var collection: CollectionReference {
        Firestore.firestore().collection("subscription")
    }

    var docRef: DocumentReference {
        Self.collection.document(id)
    }

    func toCreateDict() -> [String: Any] {
        [
            "userId": userId,
            "storeId": storeId,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}

