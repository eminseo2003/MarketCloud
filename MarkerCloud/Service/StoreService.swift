//
//  StoreService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

private struct StoreDoc: Decodable {
    let storeName: String?
    let profileImageURL: String?
}

enum StoreService {
    static let db = Firestore.firestore()
    
    // storeId로 점포명만 가져오기
    static func fetchStoreName(storeId: String) async -> String? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let data = snap.data() else { return nil }
            return data["storeName"] as? String
        } catch {
            print("[StoreService] fetchStoreName error:", error)
            return nil
        }
    }
    
    // storeId로 프로필 이미지 URL 가져오기
    // 1) 문서의 profileImageURL 사용
    // 2) 없으면 Storage 경로 stores/{storeId}/profile.jpg 시도 (폴백)
    static func fetchStoreProfileURL(storeId: String) async -> URL? {
        do {
            let snap = try await db.collection("stores").document(storeId).getDocument()
            guard let dict = snap.data(),
                  let urlStr = dict["profileImageURL"] as? String,
                  !urlStr.isEmpty,
                  let url = URL(string: urlStr) else {
                return nil
            }
            return url
        } catch {
            return nil
        }
    }
    
    static func fetchStoreBasics(storeId: String) async -> (name: String?, profileURL: URL?) {
        async let name = fetchStoreName(storeId: storeId)
        async let url  = fetchStoreProfileURL(storeId: storeId)
        return await (name, url)
    }
}
