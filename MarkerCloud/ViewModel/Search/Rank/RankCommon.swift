//
//  RankCommon.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation

struct RankResponse<T: Decodable>: Decodable {
    let responseDto: T
    let error: String?
    let success: Bool
}

func prettyJSON(_ data: Data) -> String? {
    guard
        let obj = try? JSONSerialization.jsonObject(with: data),
        let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
        let s = String(data: d, encoding: .utf8)
    else { return nil }
    return s
}

func rlog(_ tag: String, _ items: Any...) {
    print("[\(tag)]", items.map { "\($0)" }.joined(separator: " "))
}

