//
//  FeedLikeVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/29/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FeedLikeVM: ObservableObject {
    @Published var isLiked = false          // 내가 이 피드를 좋아요 중인지
    @Published var likesCount = 0           // 이 피드의 총 좋아요 수
    @Published var isBusy = false           // 중복 탭 방지
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var likeDocListener: ListenerRegistration?
    private var _feedId: String?
    private var _userId: String?

    func start(feedId: String, userId: String) async {
        stop()
        _feedId = feedId
        _userId = userId
        guard !feedId.isEmpty, !userId.isEmpty else { return }

        let like = FeedLike(userId: userId, feedId: feedId)
        likeDocListener = like.docRef.addSnapshotListener { [weak self] snap, _ in
            Task { @MainActor in
                self?.isLiked = (snap?.exists ?? false)
            }
        }

        await refreshCount()
    }

    func stop() {
        likeDocListener?.remove()
        likeDocListener = nil
    }

    func toggle() async {
        guard !isBusy else { return }
        guard let feedId = _feedId, let userId = _userId,
              !feedId.isEmpty, !userId.isEmpty else {
            errorMessage = "로그인이 필요합니다."
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        let like = FeedLike(userId: userId, feedId: feedId)

        do {
            if isLiked {
                try await like.docRef.delete()
            } else {
                try await like.docRef.setData(like.toCreateDict(), merge: false)
            }
            await refreshCount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshCount() async {
        guard let feedId = _feedId, !feedId.isEmpty else { return }
        do {
            let q = db.collection("feedLikes").whereField("feedId", isEqualTo: feedId)
            let countSnap = try await q.count.getAggregation(source: .server)
            likesCount = Int(truncating: countSnap.count)
        } catch {
            
        }
    }
}
