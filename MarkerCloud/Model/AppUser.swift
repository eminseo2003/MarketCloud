//
//  KakaoUser.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var email: String
    var userName: String
    var profileURL: URL?
    var provider: String
    var storeIds: [String] = []

    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id, email, userName, profileURL, provider, createdAt, updatedAt
    }
}

extension AppUser {
    init(firebaseUser: FirebaseAuth.User, provider: String) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.userName = firebaseUser.displayName ?? ""
        self.profileURL = firebaseUser.photoURL
        self.provider = provider
        self.storeIds = []
        self.createdAt = nil
        self.updatedAt = nil
    }
}

extension AppUser {
    static var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    static func docRef(uid: String) -> DocumentReference {
        collection.document(uid)
    }
    func toMergeDict(includeCreatedAtIfNil: Bool = true) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "email": email,
            "userName": userName,
            "profileURL": profileURL?.absoluteString as Any,
            "provider": provider,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if includeCreatedAtIfNil && createdAt == nil {
            dict["createdAt"] = FieldValue.serverTimestamp()
        }
        return dict
    }
}

