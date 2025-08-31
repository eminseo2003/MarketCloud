//
//  RecoRow.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation

struct RecoRow: Codable {
    let q1: String
    let q2: String
    let q3: String
    let q4: String
    let top1Market: String
    let top1Score: Double
    let top2Market: String
    let top2Score: Double
    let top3Market: String
    let top3Score: Double

    enum CodingKeys: String, CodingKey {
        case q1 = "Q1_시간대"
        case q2 = "Q2_분위기"
        case q3 = "Q3_교통"
        case q4 = "Q4_체류목적"
        case top1Market = "Top1_시장"
        case top1Score  = "Top1_점수"
        case top2Market = "Top2_시장"
        case top2Score  = "Top2_점수"
        case top3Market = "Top3_시장"
        case top3Score  = "Top3_점수"
    }
}
