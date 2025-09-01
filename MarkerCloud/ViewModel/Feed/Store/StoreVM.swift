//
//  StoreVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation

@MainActor
final class StoreVM: ObservableObject {
    @Published var name: String = ""
    @Published var profileURL: URL?

    func load(storeId: String) async {
        let basics = await StoreService.fetchStoreBasics(storeId: storeId)
        self.name = basics.name ?? ""
        self.profileURL = basics.profileURL
    }
}
