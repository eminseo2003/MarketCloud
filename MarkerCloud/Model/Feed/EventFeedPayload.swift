//
//  EventFeedPayload.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import Foundation

struct EventFeedPayload: Codable, Hashable {
    var eventName: String          // 이벤트명
    var description: String?       // 이벤트 설명
    var imgUrl: String?               // 이벤트 이미지
    var startAt: Date?             // 시작일자
    var endAt: Date?               // 종료일자
}
