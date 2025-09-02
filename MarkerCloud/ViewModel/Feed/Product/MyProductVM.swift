//
//  MyProductVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/3/25.
//

import Foundation
import FirebaseFirestore

struct ProductFeedLite: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let mediaUrl: URL?
    let updatedAt: Date?
    let storeId: String
}

@MainActor
final class MyProductVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasProduct = false
    @Published var products: [ProductFeedLite] = []

    private var listener: ListenerRegistration?

    func start(
        userId: String,
        marketId: Int? = nil,
        includeDrafts: Bool = false,
        limit: Int = 50
    ) {
        stop()

        isLoading = true
        errorMessage = nil

        var q: Query = Firestore.firestore().collection("feeds")
            .whereField("userId", isEqualTo: userId)
            .whereField("promoKind", isEqualTo: "product")
            .order(by: "updatedAt", descending: true)
            .limit(to: limit)

        if !includeDrafts {
            q = q.whereField("isPublished", isEqualTo: true)
        }
        if let marketId {
            q = q.whereField("marketId", isEqualTo: marketId)
        }

        listener = q.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }
            Task { @MainActor in
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    self.isLoading = false
                    return
                }
                guard let docs = snap?.documents else {
                    self.products = []
                    self.hasProduct = false
                    self.isLoading = false
                    return
                }

                let items: [ProductFeedLite] = docs.map { d in
                    let data = d.data()
                    let title = (data["title"] as? String) ?? ""
                    let body  = (data["body"] as? String) ?? ""
                    let storeId = (data["storeId"] as? String) ?? ""
                    let mediaUrlStr = data["mediaUrl"] as? String
                    let mediaUrl = mediaUrlStr.flatMap(URL.init(string:))
                    let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                    return ProductFeedLite(
                        id: d.documentID,
                        title: title,
                        body: body,
                        mediaUrl: mediaUrl,
                        updatedAt: updatedAt,
                        storeId: storeId
                    )
                }

                self.products = items
                self.hasProduct = !items.isEmpty
                self.isLoading = false
            }
        }
    }

    func checkExistence(
        userId: String,
        marketId: Int? = nil,
        includeDrafts: Bool = false
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var q: Query = Firestore.firestore().collection("feeds")
                .whereField("userId", isEqualTo: userId)
                .whereField("promoKind", isEqualTo: "product")
                .limit(to: 1)

            if !includeDrafts {
                q = q.whereField("isPublished", isEqualTo: true)
            }
            if let marketId {
                q = q.whereField("marketId", isEqualTo: marketId)
            }

            let snap = try await q.getDocuments()
            self.hasProduct = !(snap.documents.isEmpty)
        } catch {
            self.errorMessage = error.localizedDescription
            self.hasProduct = false
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

}
