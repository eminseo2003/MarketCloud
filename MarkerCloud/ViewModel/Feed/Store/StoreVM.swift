//
//  StoreVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class StoreHeaderVM: ObservableObject {
    @Published var name: String = ""
    @Published var profileURL: String?
    
    func load(storeId: String) async {
        let basics = await StoreService.fetchStoreBasics(storeId: storeId)
        self.name = basics.name ?? ""
        self.profileURL = basics.profileURL?.absoluteString
    }
}
@MainActor
final class StoreVM: ObservableObject {
    @Published var storeName: String = ""
    @Published var profileImageURL: String?
    @Published var marketId: String?
    @Published var categoryId: Int?
    @Published var phoneNumber: String?
    @Published var weekdayStart: Date?
    @Published var weekdayEnd: Date?
    @Published var weekendStart: Date?
    @Published var weekendEnd: Date?
    @Published var address: String?
    @Published var paymentMethods: Set<PaymentMethod> = []
    @Published var storeDescript: String?
    @Published var feeds: [Feed] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func load(storeId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let store = await StoreService.fetchStore(storeId: storeId)
        self.storeName = store.storeName ?? ""
        self.profileImageURL = store.profileImageURL?.absoluteString
        self.marketId = store.marketId
        self.categoryId = store.categoryId
        self.phoneNumber = store.phoneNumber
        self.weekdayStart = store.weekdayStart
        self.weekdayEnd = store.weekdayEnd
        self.weekendStart = store.weekendStart
        self.weekendEnd = store.weekendEnd
        self.address = store.address
        self.paymentMethods = store.paymentMethods
        self.storeDescript = store.storeDescript
        self.feeds = store.feeds
    }
}
@MainActor
final class StoreStatsVM: ObservableObject {
    @Published var totalLikes = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func refresh(storeId: String) async {
        guard !storeId.isEmpty else {
            totalLikes = 0
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let feedSnap = try await db.collection("feeds")
                .whereField("storeId", isEqualTo: storeId)
                .getDocuments()

            let feedIds: [String] = feedSnap.documents.map { $0.documentID }

            var sum = 0
            try await withThrowingTaskGroup(of: Int.self) { group in
                for fid in feedIds {
                    group.addTask { [db] in
                        let q = db.collection("feedLikes").whereField("feedId", isEqualTo: fid)
                        let agg = try await q.count.getAggregation(source: .server)
                        return Int(truncating: agg.count)
                    }
                }
                for try await c in group {
                    sum += c
                }
            }

            self.totalLikes = sum
        } catch {
            self.errorMessage = error.localizedDescription
            self.totalLikes = 0
        }
    }
}
