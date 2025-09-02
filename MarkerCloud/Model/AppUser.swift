//
//  KakaoUser.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// 앱에서 사용하는 사용자 모델.
// Identifiable: 리스트 바인딩 등에 사용하기 쉽도록 id 제공
// Codable: Firestore <-> Swift 객체 간 인코딩/디코딩
// Hashable: Set/Dictionary 키로 사용 가능
struct AppUser: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // users/{docID}의 docID가 여기에 들어옴
    var email: String
    var userName: String
    var profileURL: URL?
    var provider: String
    var storeIds: [String]

    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?

    // 커스텀 키를 선언하면 여기에 적힌 키만 인코딩/디코딩 대상이 됩니다.
    enum CodingKeys: String, CodingKey {
        case id, email, userName, profileURL, provider, storeIds, createdAt, updatedAt
    }
    init(id: String? = nil,
             email: String = "",
             userName: String = "",
             profileURL: URL? = nil,
             provider: String = "",
             storeIds: [String] = [],
             createdAt: Date? = nil,
             updatedAt: Date? = nil) {
            self.id = id
            self.email = email
            self.userName = userName
            self.profileURL = profileURL
            self.provider = provider
            self.storeIds = storeIds
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id        = try c.decodeIfPresent(String.self, forKey: .id)
            email     = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
            userName  = try c.decodeIfPresent(String.self, forKey: .userName) ?? ""
            if let urlStr = try c.decodeIfPresent(String.self, forKey: .profileURL) {
                profileURL = URL(string: urlStr)
            } else {
                profileURL = nil
            }
            provider  = try c.decodeIfPresent(String.self, forKey: .provider) ?? ""
            storeIds  = try c.decodeIfPresent([String].self, forKey: .storeIds) ?? []
            // @ServerTimestamp는 Date로 두면 FirestoreSwift가 자동 변환해줍니다.
            createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
            updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt)
        }
    func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(id, forKey: .id)
            try c.encode(email, forKey: .email)
            try c.encode(userName, forKey: .userName)
            try c.encodeIfPresent(profileURL?.absoluteString, forKey: .profileURL)
            try c.encode(provider, forKey: .provider)
            try c.encode(storeIds, forKey: .storeIds)
            // createdAt / updatedAt 는 서버 타임스탬프를 쓰므로 보통 encode 생략
        }
}

// FirebaseAuth.User에서 기본 정보를 가져와 AppUser를 구성.
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
    // users 컬렉션 참조
    static var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    // 특정 사용자 문서 참조 (users/{uid})
    static func docRef(uid: String) -> DocumentReference {
        collection.document(uid)
    }
    // Firestore에 merge로 저장할 때 쓰기 좋은 Dictionary 생성.
    func toMergeDict(includeCreatedAtIfNil: Bool = true) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "email": email,
            "userName": userName,
            "provider": provider,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let urlStr = profileURL?.absoluteString {
            dict["profileURL"] = urlStr
        }
        if includeCreatedAtIfNil && createdAt == nil {
            dict["createdAt"] = FieldValue.serverTimestamp()
        }
        return dict
    }

}

