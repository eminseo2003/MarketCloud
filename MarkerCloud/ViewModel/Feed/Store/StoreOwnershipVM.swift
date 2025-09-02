//
//  StoreOwnershipVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseAuth

@MainActor
final class StoreOwnershipVM: ObservableObject {
    @Published var isOwner = false
    @Published var isLoading = false

    func refresh(storeId: String, userDocId: String?, uid: String? = Auth.auth().currentUser?.uid) async {
        isLoading = true; defer { isLoading = false }
        isOwner = await UserStoreService.userOwnsStore(storeId: storeId, userDocId: userDocId, uid: uid)
        print("[StoreOwnershipVM] userOwnsStore(storeId=\(storeId)) =", isOwner)
      }
}
