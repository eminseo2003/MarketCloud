//
//  ProductCategory.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct ProductFeedPayload: Codable, Hashable {
    var productName: String        // 상품명
    var description: String?       // 상품설명
    var imgUrl: URL               // 상품이미지

    var productCategoryId: Int?

    var category: StoreCategory? {
        get { productCategoryId.flatMap { StoreCategory(rawValue: $0) } }
        set { productCategoryId = newValue?.rawValue }
    }

}
