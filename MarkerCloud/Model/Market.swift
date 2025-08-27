//
//  Market.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import Foundation

struct Market: Identifiable, Codable, Hashable {
    let id: UUID
    let marketName: String
    let imageName: URL
    let memo: String
    let address: String
}
//struct Market: Identifiable, Codable, Hashable {
//    let id: UUID
//    let marketCode: String
//    let marketName: String
//    let address: String
//}
