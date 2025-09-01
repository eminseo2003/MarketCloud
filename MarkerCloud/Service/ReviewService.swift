//
//  ReviewService.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/2/25.
//

import Foundation
import FirebaseFirestore

enum ReviewService {
    static func fetchReviews(feedId: String, limit: Int = 50) async -> [Review] {
        do {
            let db = Firestore.firestore()
            let snap = try await db.collection("reviews")
                .whereField("feedId", isEqualTo: feedId)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .getDocuments()

            return snap.documents.compactMap { doc in
                let d = doc.data()
                guard let userId   = d["userId"] as? String,
                      let content  = d["content"] as? String
                else { return nil }

                let ratingAny = d["rating"]
                let rating: Double = (ratingAny as? Double)
                    ?? (ratingAny as? Int).map(Double.init)
                    ?? (ratingAny as? String).flatMap(Double.init)
                    ?? 0

                let imageStr = (d["imageURL"] as? String) ?? (d["imageUrl"] as? String)
                let imageURL = imageStr.flatMap(URL.init(string:))

                let createdAt = (d["createdAt"] as? Timestamp)?.dateValue()

                return Review(
                    userId: userId,
                    feedId: feedId,
                    createdAt: createdAt,
                    content: content,
                    imageURL: imageURL,
                    rating: rating
                )
            }
        } catch {
            print("[ReviewService] fetchReviews error:", error)
            do {
                let db = Firestore.firestore()
                let snap = try await db.collection("reviews")
                    .whereField("feedId", isEqualTo: feedId)
                    .limit(to: limit)
                    .getDocuments()

                let items: [Review] = snap.documents.compactMap { doc in
                    let d = doc.data()
                    guard let userId   = d["userId"] as? String,
                          let content  = d["content"] as? String
                    else { return nil }

                    let ratingAny = d["rating"]
                    let rating: Double = (ratingAny as? Double)
                        ?? (ratingAny as? Int).map(Double.init)
                        ?? (ratingAny as? String).flatMap(Double.init)
                        ?? 0

                    let imageStr = (d["imageURL"] as? String) ?? (d["imageUrl"] as? String)
                    let imageURL = imageStr.flatMap(URL.init(string:))
                    let createdAt = (d["createdAt"] as? Timestamp)?.dateValue()

                    return Review(
                        userId: userId,
                        feedId: feedId,
                        createdAt: createdAt,
                        content: content,
                        imageURL: imageURL,
                        rating: rating
                    )
                }
                print("[ReviewService] 리뷰 개수", items.count)
                return items.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            } catch {
                print("[ReviewService] fallback fetchReviews error:", error)
                return []
            }
        }
    }
    static func fetchReviewCount(feedId: String) async -> Int {
            do {
                let db = Firestore.firestore()
                let q = db.collection("reviews")
                    .whereField("feedId", isEqualTo: feedId)

                let agg = q.count
                let snap = try await agg.getAggregation(source: .server)
                return snap.count.intValue
            } catch {
                print("[ReviewService] fetchReviewCount error:", error)
                return 0
            }
        }
}

