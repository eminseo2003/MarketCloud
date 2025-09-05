//
//  MyReviewsVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/5/25.
//

import Foundation
import FirebaseFirestore
import OSLog

@MainActor
final class MyReviewsVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var reviews: [Review] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MarkerCloud",
                             category: "MyReviewsVM")

    func start(userId: String) {
        log.debug("start(userId: \(userId, privacy: .public))")
        isLoading = true
        errorMessage = nil
        listener?.remove()

        listener = db.collection("reviews")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener(includeMetadataChanges: false) { [weak self]
                (snap: QuerySnapshot?, err: Error?) in
                guard let self else { return }

                if let err = err {
                    self.errorMessage = err.localizedDescription
                    self.isLoading = false
                    self.log.error("listen reviews error: \(err.localizedDescription, privacy: .public)")
                    return
                }

                let items: [Review] = snap?.documents.compactMap {
                    try? $0.data(as: Review.self)
                } ?? []

                self.reviews = items.sorted {
                    ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                }
                self.isLoading = false
                self.log.debug("reviews updated: \(self.reviews.count)")
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
        log.debug("stop listener")
    }

    func refresh(userId: String) {
        start(userId: userId)
    }
}
