//
//  Subscription.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct Subscription: Codable, Hashable, Identifiable {
    var userid: Int64
    var storeid: Int64
    var createdAt: Date

    var id: String { "\(userid)-\(storeid)" }
}
