//
//  FeedViewModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation
import FirebaseFirestore

struct FeedItem: Identifiable, Hashable {
    let id: String
    let storeId: String
    let title: String
    let body: String
    let mediaUrl: URL?
    let mediaType: String   // "image" | "video"
    let promoKind: String   // "store" | "product" | "event"
    let marketId: Int
    let createdAt: Date?
    let updatedAt: Date?
    
    var isImage: Bool { mediaType == "image" }
    var isVideo: Bool { mediaType == "video" }
}

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var feeds: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    func start(marketId: Int, limit: Int = 100) {
        stop()
        isLoading = true
        errorMessage = nil
        feeds = []

        let db = Firestore.firestore()
        let q = db.collection("feeds")
            .whereField("marketId", isEqualTo: marketId)
            .order(by: "updatedAt", descending: true)
            .limit(to: limit)

        listener = q.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }
            if let err = err {
                self.isLoading = false
                self.errorMessage = err.localizedDescription
                return
            }
            guard let snap = snap else {
                self.isLoading = false
                self.errorMessage = "스냅샷이 비어 있습니다."
                return
            }

            let items: [FeedItem] = snap.documents.compactMap { doc in
                let d = doc.data()
                let id = d["id"] as? String ?? doc.documentID
                let storeId = d["storeId"] as? String ?? ""
                let title = d["title"] as? String ?? ""
                let body = d["body"] as? String ?? ""
                let mediaType = d["mediaType"] as? String ?? "image"
                let promoKind = d["promoKind"] as? String ?? "store"
                let marketId = d["marketId"] as? Int ?? 0
                let mediaUrlStr = d["mediaUrl"] as? String
                let mediaUrl = mediaUrlStr.flatMap(URL.init(string:))
                let createdAt = (d["createdAt"] as? Timestamp)?.dateValue()
                let updatedAt = (d["updatedAt"] as? Timestamp)?.dateValue()

                return FeedItem(
                    id: id,
                    storeId: storeId,
                    title: title,
                    body: body,
                    mediaUrl: mediaUrl,
                    mediaType: mediaType,
                    promoKind: promoKind,
                    marketId: marketId,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }

            self.feeds = items.sorted {
                let lhs = $0.updatedAt ?? $0.createdAt ?? .distantPast
                let rhs = $1.updatedAt ?? $1.createdAt ?? .distantPast
                return lhs > rhs
            }
            self.isLoading = false
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }
}
