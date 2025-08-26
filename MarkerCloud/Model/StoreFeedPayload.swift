//
//  StoreFeedPayload.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct StoreFeedPayload: Codable, Hashable {
    var description: String?       // 점포설명
    var imgUrl: URL?               // 점포이미지
}
