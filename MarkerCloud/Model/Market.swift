//
//  Market.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import Foundation

struct Market: Identifiable, Codable, Hashable {
    let id: Int
    let marketName: String
    let marketImg: String
    let address: String
}
let traditionalMarkets: [Market] = (1...20).map { code in
    Market(
        id: code,
        marketName: marketNameMap[code] ?? "이름 미정",
        marketImg: marketImgMap[code] ?? "이미지 미정",
        address: marketAddressMap[code] ?? "주소 미정"
    )
}
private let marketNameMap: [Int: String] = [
    1: "용두시장",
    2: "서울악령시장",
    3: "경동광성상가",
    4: "경동시장",
    5: "청량리수산시장",
    6: "청량리종합시장",
    7: "청량종합도매시장",
    8: "청량리농수산물시장",
    9: "동서시장",
    10: "청량리청과물시장",
    11: "청량리전통시장",
    12: "동부시장",
    13: "답십리건축자재시장",
    14: "회기시장",
    15: "전농로터리시장",
    16: "답십리시장",
    17: "답십리현대시장",
    18: "이문제일시장",
    19: "이경시장",
    20: "전곡시장"
]
private let marketImgMap: [Int: String] = [
    1: "market1", //용두시장
    2: "market2", //서울악령시장
    3: "market3", //경동광성상가
    4: "market4", //경동시장
    5: "market5", //청량리수산시장
    6: "market6", //청량리종합시장
    7: "market7", //청량종합도매시장
    8: "market8", //청량리농수산물시장
    9: "market9", //동서시장
    10: "market10", //청량리청과물시장
    11: "market11", //청량리전통시장
    12: "market12", //동부시장
    13: "market13", //답십리건축자재시장
    14: "market14", //회기시장
    15: "market15", //전농로터리시장
    16: "market16", //답십리시장
    17: "market17", //답십리현대시장
    18: "market18", //이문제일시장
    19: "market19", //이경시장
    20: "market20", //전곡시장
]
private let marketAddressMap: [Int: String] = [
    1: "무학로37길12(용두동)", //용두시장
    2: "약령중앙로 26", //서울악령시장
    3: "고산자로 464", //경동광성상가
    4: "고산자로36길 3(제기동)", //경동시장
    5: "고산자로34길 48-1(용두동)", //청량리수산시장
    6: "홍릉로1길 68-3", //청량리종합시장
    7: "약령시로 92-2(제기동)", //청량종합도매시장
    8: "경동시장로 22", //청량리농수산물시장
    9: "왕산로33길13(제기동)", //동서시장
    10: "왕산로33길 6(제기동)", //청량리청과물시장
    11: "홍릉로1가길 5", //청량리전통시장
    12: "천호대로281(답십리동495-1)", //동부시장
    13: "고미술로 49", //답십리건축자재시장
    14: "회기로25길 21(회기동)", //회기시장
    15: "전농로147(전농동)", //전농로터리시장
    16: "답십리로51길 4-1", //답십리시장
    17: "전농로4길 1", //답십리현대시장
    18: "이문로 200(이문동250-1)", //이문제일시장
    19: "휘경로53(휘경동 151-3)", //이경시장
    20: "한천로190(장안동)", //전곡시장
]

