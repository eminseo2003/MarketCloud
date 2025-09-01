//
//  Generate.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/27/25.
//

import Foundation

//// 서버 응답 전체
//struct GenerateResponse: Codable {
//    let responseDto: GenerateDTO
//    let error: String?
//    let success: Bool
//}
//
//// 생성 결과 DTO
//struct GenerateDTO: Codable, Hashable, Identifiable {
//    let feedMediaUrl: String
//    let feedBody: String
//    var id: String { feedMediaUrl }
//
//    // 서버가 feedMediaUrl 또는 feedMediaUrl1로 보낼 가능성 둘 다 대응
//    enum CodingKeys: String, CodingKey { case feedMediaUrl, feedBody }
//
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        self.feedMediaUrl =
//            try c.decode(String.self, forKey: .feedMediaUrl)
//        self.feedBody = try c.decode(String.self, forKey: .feedBody)
//    }
//}



