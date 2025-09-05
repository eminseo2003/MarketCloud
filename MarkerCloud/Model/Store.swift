//
//  Store.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/31/25.
//

import Foundation

enum StoreCategory: Int, Codable, CaseIterable, Identifiable, Hashable {
    case restaurant = 1
    case sideDishes = 2
    case cafeBakerySnacks = 3
    case clothing = 4
    case hanbokBeddingWedding = 5
    case fashionBeauty = 6
    case livingKitchenStationery = 7
    case flowersInstrumentsArt = 8
    case agriHardware = 9
    case photoBeautyGame = 10
    case seafood = 11
    case meat = 12
    case fruitsVegetables = 13
    case other = 14
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .restaurant:               return "음식점"
        case .sideDishes:               return "반찬"
        case .cafeBakerySnacks:         return "카페·제과·간식"
        case .clothing:                 return "옷가게"
        case .hanbokBeddingWedding:     return "한복·이불·혼수"
        case .fashionBeauty:            return "패션잡화·화장품"
        case .livingKitchenStationery:  return "생활·주방·문구"
        case .flowersInstrumentsArt:    return "꽃·악기·화구"
        case .agriHardware:             return "농자재·철물"
        case .photoBeautyGame:          return "사진·뷰티·게임"
        case .seafood:                  return "수산물"
        case .meat:                     return "축산물"
        case .fruitsVegetables:         return "과일야채"
        case .other:                    return "기타"
        }
    }
    
    init?(label: String) {
        guard let found = StoreCategory.allCases.first(where: { $0.displayName == label }) else {
            return nil
        }
        self = found
    }
    
}


enum PaymentMethod: Int, CaseIterable, Identifiable, Codable, Hashable {
    case onnuriVoucher     = 1  // 온누리상품권
    case zeropay           = 2  // 제로페이
    case livelihoodCoupon  = 3  // 민생회복쿠폰
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .onnuriVoucher:     return "온누리상품권"
        case .zeropay:           return "제로페이"
        case .livelihoodCoupon:  return "민생회복쿠폰"
        }
    }
}
struct Store: Identifiable {
    let id: UUID
    let storeName: String
    let profileImageURL: URL?
    var marketId: UUID
    
    var categoryId: Int?
    
    var category: StoreCategory? {
        get { categoryId.flatMap(StoreCategory.init(rawValue:)) }
        set { categoryId = newValue?.rawValue }
    }
    var tel: String?
    var dayOpenTime: Date?
    var dayCloseTime: Date?
    var weekendOpenTime: Date?
    var weekendCloseTime: Date?
    var address: String?
    var paymentMethods: Set<PaymentMethod> = []
    var description: String?
    
    var feeds: [Feed] = []
}
