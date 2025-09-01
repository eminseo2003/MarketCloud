//
//  StoreVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation

@MainActor
final class StoreHeaderVM: ObservableObject {
    @Published var name: String = ""
    @Published var profileURL: URL?
    
    func load(storeId: String) async {
        let basics = await StoreService.fetchStoreBasics(storeId: storeId)
        self.name = basics.name ?? ""
        self.profileURL = basics.profileURL
    }
}
@MainActor
final class StoreVM: ObservableObject {
    @Published var storeName: String = ""
    @Published var profileImageURL: URL?
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
        self.profileImageURL = store.profileImageURL
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
