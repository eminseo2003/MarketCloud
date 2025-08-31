//
//  MarketRecommender.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/31/25.
//

import Foundation
import Foundation
import Combine

extension String {
    func canonPurposes() -> String {
        let parts = self
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted()
        return parts.joined(separator: ",")
    }
}

struct MarketNameNormalizer {
    private static let synonyms: [String: String] = [
        "서울악령시장": "서울약령시장",
    ]

    static func canon(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: " ", with: "")
        if let fixed = synonyms[s] { return fixed }
        return s
    }
}

final class MarketRecommender {
    static let shared = MarketRecommender()

    private var rows: [RecoRow] = []
    private var marketByName: [String: Market] = [:]

    private init() {
        loadRowsFromBundle()
        buildMarketIndex()
    }

    private func loadRowsFromBundle(jsonFileName: String = "data_all_cases") {
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
            print("\(jsonFileName).json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.rows = try JSONDecoder().decode([RecoRow].self, from: data)
        } catch {
            print("JSON decode error:", error)
        }
    }

    private func buildMarketIndex() {
        self.marketByName = Dictionary(
            uniqueKeysWithValues: traditionalMarkets.map { (MarketNameNormalizer.canon($0.marketName), $0) }
        )
    }

    func recommend(
        q1: String,
        q2: String,
        q3: String,
        q4: String,
        topK: Int = 3
    ) -> [Market] {

        let keyQ4 = q4.canonPurposes()

        guard let row = rows.first(where: {
            $0.q1 == q1 && $0.q2 == q2 && $0.q3 == q3 && $0.q4.canonPurposes() == keyQ4
        }) else {
            return []
        }

        let names = [row.top1Market, row.top2Market, row.top3Market].prefix(topK)

        var out: [Market] = []
        for raw in names {
            let canonName = MarketNameNormalizer.canon(raw)
            if let m = marketByName[canonName] {
                out.append(m)
            } else {
                out.append(
                    Market(
                        id: -1,
                        marketName: canonName,
                        marketImg: "market_default",
                        address: "주소 미정"
                    )
                )
            }
        }
        return out
    }

    func recommend(q1: String, q2: String, q3: String, q4Purposes: [String], topK: Int = 3) -> [Market] {
        recommend(q1: q1, q2: q2, q3: q3, q4: q4Purposes.joined(separator: ","), topK: topK)
    }
}
