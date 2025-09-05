//
//  FollowingStoresVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/5/25.
//

import FirebaseFirestore

struct StorefollowingLite: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let storeName: String
    let profileImageURL: String?

    var imageURL: URL? { URL(string: profileImageURL ?? "") }
}

@MainActor
final class FollowingStoresVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stores: [StorefollowingLite] = []

    private let db = Firestore.firestore()
    private var subListener: ListenerRegistration?

    func start(userId: String) {
        isLoading = true
        errorMessage = nil
        subListener?.remove()

        subListener = db.collection("subscription")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    Task { @MainActor in
                        self.errorMessage = err.localizedDescription
                        self.isLoading = false
                    }
                    return
                }

                let subs: [Subscription] = snap?.documents.compactMap {
                    try? $0.data(as: Subscription.self)
                } ?? []

                let ids = Array(Set(subs.map { $0.storeId })) // 중복 제거
                self.fetchStores(ids: ids)
            }
    }

    private func fetchStores(ids: [String]) {
        if ids.isEmpty {
            Task { @MainActor in
                self.stores = []
                self.isLoading = false
            }
            return
        }

        let chunks: [[String]] = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0..<min($0+10, ids.count)])
        }

        var result: [StorefollowingLite] = []
        let group = DispatchGroup()

        for chunk in chunks {
            group.enter()
            db.collection("stores")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snap, err in
                    defer { group.leave() }
                    if let docs = snap?.documents {
                        let part: [StorefollowingLite] = docs.compactMap { try? $0.data(as: StorefollowingLite.self) }
                        result.append(contentsOf: part)
                    } else if let err = err {
                        print("fetchStores error:", err.localizedDescription)
                    }
                }
        }

        group.notify(queue: .main) {
            self.stores = result.sorted { $0.storeName < $1.storeName }
            self.isLoading = false
        }
    }

    func stop() {
        subListener?.remove()
        subListener = nil
    }
}
