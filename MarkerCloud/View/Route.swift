//
//  Route.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/24/25.
//

import Foundation

enum Route: Hashable, Identifiable {
    case login
    case join
    case recommendMarket //시장 추천
    case selectComplete //선택 완료
    case selextMarket //시장 선택
    case pushPromotion
    case createComplete //생성 완료
    case searchResult //검색 결과
    case moreStore //점포 더보기
    case moreProduct //상품 더보기
    case moreEvent //이벤트 더보기
    case storeDetail //점포 상세(인스타페이지)
    case storepostDetail //점포 게시물 상세
    case productDetail //상품 상세
    case eventDetail //이벤트 상세
    case changeProfile
    case myStore
    case myProduct
    case myEvent
    case followingStore
    case myLiked
    case myReview
    case changeStoreInfo
    case firstStoreCreate
    var id: Self { self }
}
