//
//  StoreFeedPayload.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct StoreFeedPayload: Codable, Hashable {
    var description: String?       // AI가 생성한 점포설명
    var imgUrl: String?               // AI가 생성한 점포이미지
}
