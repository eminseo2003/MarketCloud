//
//  StoreMembershipVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class StoreMembershipVM: ObservableObject {
    @Published var hasStore = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func refresh(uid: String?, marketId: Int) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let ok = await StoreMembershipService.userHasStore(in: marketId, uid: uid)
            self.hasStore = ok
        }
    }
}
