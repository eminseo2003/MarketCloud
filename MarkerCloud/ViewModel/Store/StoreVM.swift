//
//  StoreVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore
import OSLog

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
    @Published var isSaving = false
    
    
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
extension StoreVM {
    var paymentSummary: String {
        if paymentMethods.isEmpty { return "미등록" }
        return paymentMethods.map { $0.displayName }
            .sorted()
            .joined(separator: ", ")
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

@MainActor
extension StoreVM {
    func updateName(storeId: String, newName: String) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSaving = true; errorMessage = nil
        defer { isSaving = false }
        
        do {
            try await Firestore.firestore()
                .collection("stores").document(storeId)
                .setData([
                    "storeName": trimmed,
                    "updatedAt": FieldValue.serverTimestamp()
                ], merge: true)
            
            self.storeName = trimmed
        } catch {
            self.errorMessage = "이름 저장 실패: \(error.localizedDescription)"
        }
    }
    func updateCategory(storeId: String, categoryId: Int) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        
        do {
            try await Firestore.firestore()
                .collection("stores").document(storeId)
                .setData([
                    "categoryId": categoryId,
                    "updatedAt": FieldValue.serverTimestamp()
                ], merge: true)
            
            self.categoryId = categoryId
        } catch {
            self.errorMessage = "카테고리 저장 실패: \(error.localizedDescription)"
        }
    }
    func updatePhoneNumber(storeId: String, phone: String?) async {
            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

            do {
                try await Firestore.firestore()
                    .collection("stores").document(storeId)
                    .setData([
                        "phoneNumber": phone,
                        "updatedAt": FieldValue.serverTimestamp()
                    ], merge: true)

                self.phoneNumber = phone
            } catch {
                self.errorMessage = "전화번호 저장 실패: \(error.localizedDescription)"
            }
        }
    func updateWeekdayHours(storeId: String, start: Date?, end: Date?) async {
            let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MarkerCloud",
                             category: "StoreVM")

            guard !storeId.isEmpty else {
                self.errorMessage = "잘못된 storeId"
                return
            }

            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

            let ref = Firestore.firestore().collection("stores").document(storeId)

            // 1) updateData로 먼저 시도 (삭제 포함)
            do {
                var update: [String: Any] = ["updatedAt": FieldValue.serverTimestamp()]
                update["weekdayStart"] = start != nil ? Timestamp(date: start!) : FieldValue.delete()
                update["weekdayEnd"]   = end   != nil ? Timestamp(date: end!)   : FieldValue.delete()

                log.debug("updateData weekday hours: start=\(String(describing: start), privacy: .public), end=\(String(describing: end), privacy: .public)")
                try await ref.updateData(update)

                self.weekdayStart = start
                self.weekdayEnd   = end
                return
            } catch {
                log.error("updateData failed, fallback to setData: \(error.localizedDescription, privacy: .public)")
            }

            // 2) 문서가 없을 수 있으니 setData(merge:true)로 생성/업데이트
            do {
                var data: [String: Any] = ["updatedAt": FieldValue.serverTimestamp()]
                if let s = start { data["weekdayStart"] = Timestamp(date: s) }
                if let e = end   { data["weekdayEnd"]   = Timestamp(date: e) }

                log.debug("setData(merge:true) weekday hours")
                try await ref.setData(data, merge: true)

                self.weekdayStart = start
                self.weekdayEnd   = end
            } catch {
                self.errorMessage = "평일 운영시간 저장 실패: \(error.localizedDescription)"
                log.error("\(self.errorMessage ?? "", privacy: .public)")
            }
        }
    func updateWeekEndHours(storeId: String, start: Date?, end: Date?) async {
            let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MarkerCloud",
                             category: "StoreVM")

            guard !storeId.isEmpty else {
                self.errorMessage = "잘못된 storeId"
                return
            }

            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

            let ref = Firestore.firestore().collection("stores").document(storeId)

            // 1) updateData로 먼저 시도 (삭제 포함)
            do {
                var update: [String: Any] = ["updatedAt": FieldValue.serverTimestamp()]
                update["weekendStart"] = start != nil ? Timestamp(date: start!) : FieldValue.delete()
                update["weekendEnd"]   = end   != nil ? Timestamp(date: end!)   : FieldValue.delete()

                log.debug("updateData weekday hours: start=\(String(describing: start), privacy: .public), end=\(String(describing: end), privacy: .public)")
                try await ref.updateData(update)

                self.weekdayStart = start
                self.weekdayEnd   = end
                return
            } catch {
                log.error("updateData failed, fallback to setData: \(error.localizedDescription, privacy: .public)")
            }

            // 2) 문서가 없을 수 있으니 setData(merge:true)로 생성/업데이트
            do {
                var data: [String: Any] = ["updatedAt": FieldValue.serverTimestamp()]
                if let s = start { data["weekendStart"] = Timestamp(date: s) }
                if let e = end   { data["weekendEnd"]   = Timestamp(date: e) }

                log.debug("setData(merge:true) weekday hours")
                try await ref.setData(data, merge: true)

                self.weekendStart = start
                self.weekendEnd   = end
            } catch {
                self.errorMessage = "평일 운영시간 저장 실패: \(error.localizedDescription)"
                log.error("\(self.errorMessage ?? "", privacy: .public)")
            }
        }
}
