//
//  StoreMembershipVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import OSLog

// 뷰에서 “현재 로그인한 사용자가 선택한 시장에 내 점포가 있는가?”를 질의하고, 그 결과(hasStore)를 바인딩해 주는 ViewModel.
@MainActor
final class StoreMembershipVM: ObservableObject {
    @Published var hasStore = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 선택한 시장(marketId)과 현재 사용자(appUserId)를 기준으로 보유 점포 여부를 재조회
    func refresh(appUserId: String?, marketId: Int) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }

        //호출 파라미터 로그
        print("[MembershipVM] refresh(appUserId: \(appUserId ?? "nil"), marketId: \(marketId))")

        //사용자가 없으면 질의 스킵
        guard let appUserId else {
            print("[MembershipVM] appUserId is nil → skip query")
            self.hasStore = false
            return
        }

        // createdBy == appUserId && marketId == 선택시장 인 문서 존재 여부를 확인
        let ok = await StoreMembershipService.userHasStore(in: marketId, ownerId: appUserId)
        // 결과 로그 및 상태 반영 → 뷰가 자동으로 업데이트됨
        print("[MembershipVM] userHasStore result = \(ok)")
        self.hasStore = ok
    }
}
