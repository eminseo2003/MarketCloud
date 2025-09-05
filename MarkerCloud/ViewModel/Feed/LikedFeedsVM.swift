//
//  LikedFeedsVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/5/25.
//

import Foundation
import FirebaseFirestore
import OSLog

@MainActor
final class LikedFeedsVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var feeds: [FeedLite] = []

    private let db = Firestore.firestore()
    private var likeListener: ListenerRegistration?

    private var likeTimeByFeedId: [String: Date] = [:]

    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MarkerCloud",
                             category: "LikedFeedsVM")
    private func d(_ s: String) { log.debug("\(s, privacy: .public)") }
    private func e(_ s: String) { log.error("\(s, privacy: .public)") }

    func start(userId: String) {
        d("start(userId: \(userId))")
        isLoading = true
        errorMessage = nil
        likeListener?.remove()

        likeListener = db.collection("feedLikes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener(includeMetadataChanges: false) { [weak self]
                (snap: QuerySnapshot?, err: Error?) in
                guard let self = self else { return }

                if let err = err {
                    self.e("listen feedLikes error: \(err.localizedDescription)")
                    self.errorMessage = err.localizedDescription
                    self.isLoading = false
                    return
                }

                let likes: [FeedLike] = snap?.documents.compactMap {
                    try? $0.data(as: FeedLike.self)
                } ?? []

                let likedPairs: [(id: String, at: Date)] = likes.map {
                    ($0.feedId, $0.createdAt ?? .distantPast)
                }

                var seen = Set<String>()
                let idsOrdered: [String] = likedPairs.compactMap { pair in
                    guard !seen.contains(pair.id) else { return nil }
                    seen.insert(pair.id); return pair.id
                }

                self.likeTimeByFeedId = Dictionary(uniqueKeysWithValues: likedPairs)
                self.d("likes=\(likes.count), unique feedIds=\(idsOrdered.count)")
                self.fetchFeeds(idsOrdered: idsOrdered)
            }
    }

    private func fetchFeeds(idsOrdered: [String]) {
        guard !idsOrdered.isEmpty else {
            feeds = []
            isLoading = false
            d("empty ids → clear feeds")
            return
        }

        let chunks: [[String]] = stride(from: 0, to: idsOrdered.count, by: 10).map {
            Array(idsOrdered[$0..<min($0+10, idsOrdered.count)])
        }

        var feedById: [String: FeedLite] = [:]
        let group = DispatchGroup()

        for (i, chunk) in chunks.enumerated() {
            d("fetch chunk[\(i)] size=\(chunk.count)")
            group.enter()
            db.collection("feeds")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { [weak self] snap, err in
                    defer { group.leave() }
                    guard let self = self else { return }

                    if let err = err {
                        self.e("fetch chunk[\(i)] error: \(err.localizedDescription)")
                        return
                    }

                    snap?.documents.forEach { doc in
                        if let lite = self.mapFeedLite(doc) {
                            feedById[doc.documentID] = lite
                        } else {
                            self.e("decode FeedLite 실패: \(doc.documentID)")
                        }
                    }
                }
        }

        group.notify(queue: .main) {
            let ordered: [FeedLite] = idsOrdered.compactMap { feedById[$0] }

            let finallySorted = ordered.sorted {
                let t0 = self.likeTimeByFeedId[$0.id] ?? .distantPast
                let t1 = self.likeTimeByFeedId[$1.id] ?? .distantPast
                return t0 > t1
            }

            self.feeds = finallySorted
            self.isLoading = false
            self.d("merged feeds=\(finallySorted.count)")
        }
    }

    private func mapFeedLite(_ doc: DocumentSnapshot) -> FeedLite? {
        guard let data = doc.data() else { return nil }
        let title = data["title"] as? String ?? ""
        let body = data["body"] as? String ?? ""
        let mediaUrlStr = data["mediaUrl"] as? String
        let mediaUrl = mediaUrlStr.flatMap(URL.init(string:))
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
        let storeId = data["storeId"] as? String ?? ""
        return FeedLite(id: doc.documentID,
                        title: title,
                        body: body,
                        mediaUrl: mediaUrl,
                        updatedAt: updatedAt,
                        storeId: storeId)
    }

    func stop() {
        likeListener?.remove()
        likeListener = nil
    }
}
