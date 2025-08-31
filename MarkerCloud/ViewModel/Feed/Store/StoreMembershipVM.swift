//
//  StoreMembershipVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import OSLog

@MainActor
final class StoreMembershipVM: ObservableObject {
    @Published var hasStore = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func refresh(appUserId: String?, marketId: Int) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }

        print("[MembershipVM] refresh(appUserId: \(appUserId ?? "nil"), marketId: \(marketId))")

        guard let appUserId else {
            print("[MembershipVM] appUserId is nil → skip query")
            self.hasStore = false
            return
        }

        let ok = await StoreMembershipService.userHasStore(in: marketId, ownerId: appUserId)
        print("[MembershipVM] userHasStore result = \(ok)")
        self.hasStore = ok
    }
}
