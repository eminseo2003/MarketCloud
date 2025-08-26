//
//  AppModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/16/25.
//

import Foundation

let kDummyImageURL = URL(string:
  "https://c.pxhere.com/photos/88/8a/cat_lying_blue_eye_small_ginger_fur_heal_pet_animal-609263.jpg!d"
)!
let kDummyVideoURL = URL(string:
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
)!
enum DummyUserIDs {
    static let user1 = "123"
    static let user2 = "234"
    static let user3 = "345"
    static let user4 = "456"
    static let user5 = "567"

    static let all = [user1, user2, user3, user4, user5]
}
fileprivate func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
    var comp = DateComponents()
    comp.year = y; comp.month = m; comp.day = d
    return Calendar.current.date(from: comp) ?? Date()
}
let dummyUsers: [User] = [
    User(id: DummyUserIDs.user1,
         password: "pw1234!",
         name: "김가을",
         email: "fall.kim@example.com",
         createdAt: date(2024, 9, 12),
         imgUrl: kDummyImageURL),

    User(id: DummyUserIDs.user2,
         password: "pw5678!",
         name: "이봄",
         email: "spring.lee@example.com",
         createdAt: date(2024, 10, 3),
         imgUrl: kDummyImageURL),

    User(id: DummyUserIDs.user3,
         password: "pwabcd12",
         name: "박여름",
         email: nil, // 이메일 없는 케이스
         createdAt: date(2025, 1, 8),
         imgUrl: kDummyImageURL),

    User(id: DummyUserIDs.user4,
         password: "pw!market",
         name: "최동해",
         email: "east.choi@example.com",
         createdAt: date(2025, 3, 21),
         imgUrl: kDummyImageURL),

    User(id: DummyUserIDs.user5,
         password: "pw99@@",
         name: "정겨울",
         email: "winter.jeong@example.com",
         createdAt: date(2025, 6, 2),
         imgUrl: kDummyImageURL)
]

enum DummyMarketIDs {
    static let marketOne = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let marketTwo = UUID(uuidString: "11111111-1111-1111-1111-111111111112")!
    static let marketThree = UUID(uuidString: "11111111-1111-1111-1111-111111111113")!
    static let marketFour = UUID(uuidString: "11111111-1111-1111-1111-111111111114")!
    static let marketFive = UUID(uuidString: "11111111-1111-1111-1111-111111111115")!
    static let marketSix = UUID(uuidString: "11111111-1111-1111-1111-111111111116")!
    static let marketSeven = UUID(uuidString: "11111111-1111-1111-1111-111111111117")!
    static let marketEight = UUID(uuidString: "11111111-1111-1111-1111-111111111118")!
    static let marketNine = UUID(uuidString: "11111111-1111-1111-1111-111111111119")!
    static let marketTen = UUID(uuidString: "11111111-1111-1111-1111-111111111120")!
}
let dummyMarkets: [Market] = [
    Market(
        id: DummyMarketIDs.marketOne,
        marketName: "시장 하나",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketTwo,
        marketName: "시장 둘",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketThree,
        marketName: "시장 셋",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketFour,
        marketName: "시장 넷",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketFive,
        marketName: "시장 다섯",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketSix,
        marketName: "시장 여섯",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketSeven,
        marketName: "시장 일곱",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketEight,
        marketName: "시장 여덟",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketNine,
        marketName: "시장 아홉",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    ),
    Market(
        id: DummyMarketIDs.marketTen,
        marketName: "시장 열",
        imageName: kDummyImageURL,
        memo: "시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명 시장에 대한 간결한 설명",
        address: "서울특별시 강남구 강남대로101길 101"
    )
]

fileprivate func time(_ hour: Int, _ minute: Int) -> Date? {
    Calendar.current.date(from: DateComponents(hour: hour, minute: minute))
}
enum DummyStoreIDs {
    static let coffeeKing  = UUID(uuidString: "A9E7D3C0-7B1B-4A7F-8F73-6C8A6D0A1111")!
    static let coffeeWang  = UUID(uuidString: "93C2A190-6D6C-4E5B-B145-1D4E6D091111")!
    static let coffeeZzang = UUID(uuidString: "B1F4E2A9-4F3B-49C1-9A7D-2D0C8B2B2222")!
    static let breadSister = UUID(uuidString: "C3D2B1A0-9E8D-4C7A-8123-5F6E7D0C3333")!
}
let dummyStores: [Store] = [
    Store(
        id: DummyStoreIDs.coffeeKing,
        storeName: "커피킹",
        profileImageURL: kDummyImageURL,
        marketId: DummyMarketIDs.marketOne,
        categoryId: StoreCategory.cafeBakerySnacks.rawValue,
        tel: "02-1234-5678",
        dayOpenTime: time(9, 0),
        dayCloseTime: time(18, 0),
        weekendOpenTime: time(10, 0),
        weekendCloseTime: time(17, 0),
        address: "서울특별시 동대문구 어쩌고 501 120 301",
        paymentMethods: Set([.onnuriVoucher, .zeropay]),
        description: "스페셜티 원두로 내리는 드립/에스프레소 전문.",
        feeds: dummyFeed.filter { $0.storeId == DummyStoreIDs.coffeeKing }
    ),
    Store(
        id: DummyStoreIDs.coffeeWang,
        storeName: "커피왕점포",
        profileImageURL: kDummyImageURL,
        marketId: DummyMarketIDs.marketOne,
        categoryId: StoreCategory.cafeBakerySnacks.rawValue,
        tel: "02-1234-5678",
        dayOpenTime: time(9, 0),
        dayCloseTime: time(18, 0),
        weekendOpenTime: time(10, 0),
        weekendCloseTime: time(17, 0),
        address: "서울특별시 동대문구 어쩔로 50길 100 301",
        paymentMethods: Set([.onnuriVoucher, .zeropay]),
        description: "핸드드립 전문 카페입니다.",
        feeds: dummyFeed.filter { $0.storeId == DummyStoreIDs.coffeeWang }
        ),
    Store(id: DummyStoreIDs.coffeeZzang,
          storeName: "커피짱점포",
          profileImageURL: kDummyImageURL,
          marketId: DummyMarketIDs.marketOne,
          categoryId: StoreCategory.sideDishes.rawValue,
          tel: "02-1234-5678",
          dayOpenTime: time(9, 0),
          dayCloseTime: time(18, 0),
          weekendOpenTime: time(10, 0),
          weekendCloseTime: time(17, 0),
          address: "서울특별시 동대문구 어쩔로 50길 100 301",
          paymentMethods: Set([.onnuriVoucher, .zeropay]),
          description: "핸드드립 전문 카페입니다.",
          feeds: dummyFeed.filter { $0.storeId == DummyStoreIDs.coffeeZzang }
         ),
    Store(id: DummyStoreIDs.breadSister, storeName: "빵굽는언니점포", profileImageURL: kDummyImageURL, marketId: DummyMarketIDs.marketTwo,
          categoryId: StoreCategory.sideDishes.rawValue,
          tel: "02-1234-5678",
          dayOpenTime: time(9, 0),
          dayCloseTime: time(18, 0),
          weekendOpenTime: time(10, 0),
          weekendCloseTime: time(17, 0),
          address: "서울특별시 동대문구 어쩔로 50길 100 301",
          paymentMethods: Set([.onnuriVoucher, .zeropay]),
          description: "핸드드립 전문 카페입니다.",
          feeds: dummyFeed.filter { $0.storeId == DummyStoreIDs.breadSister }
         )
]

enum DummyFeedIDs {
    static let feed1 = "F-00000000-0000-0000-0000-000000000001"
    static let feed2 = "F-00000000-0000-0000-0000-000000000002"
    static let feed3 = "F-00000000-0000-0000-0000-000000000003"
    static let feed4 = "F-00000000-0000-0000-0000-000000000004"
    static let feed5 = "F-00000000-0000-0000-0000-000000000005"
    static let feed6 = "F-00000000-0000-0000-0000-000000000006"

}
let dummyFeed: [Feed] = [
    Feed(
        id: DummyFeedIDs.feed1,
        storeId: DummyStoreIDs.coffeeKing,
        promoKind: .event,
        mediaType: .image,
        title: "fwjnofsd이벤트/사진",
        prompt: "ㅇㅇ러주대러주낻",
        mediaUrl: kDummyImageURL,
        body: "주더ㅜㄹ잳어ㅑㅐㅔㅈㄴ",
        createdAt: Date(),
        event: EventFeedPayload(
            eventName: "가을맞이 할인",
            description: "전 품목 10%~30%",
            imgUrl: kDummyImageURL,
            startAt: Date(),
            endAt: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ),
        storeInfo: nil,
        product: nil,
        reviews: sampleReviews
    ),
    Feed(
        id: DummyFeedIDs.feed2,
        storeId: DummyStoreIDs.breadSister,
        promoKind: .product,
        mediaType: .image,
        title: "fwfwegthge상품/사진",
        prompt: "이 상품으로 홍보문구 생성",
        mediaUrl: kDummyImageURL,
        body: "산지직송 사과 특가!",
        createdAt: Date(),
        event: nil,
        storeInfo: nil,
        product: ProductFeedPayload(
            productName: "아오리 사과 3kg",
            description: "새콤달콤 아삭",
            imgUrl: kDummyImageURL,
            productCategoryId: StoreCategory.meat.rawValue
        ),
        reviews: sampleReviews
    ),
    Feed(
        id: DummyFeedIDs.feed3,
        storeId: DummyStoreIDs.breadSister,
        promoKind: .product,
        mediaType: .video,
        title: "fewfedw상품/비디오",
        prompt: "이 상품으로 홍보문구 생성",
        mediaUrl: kDummyVideoURL,
        body: "산지직송 사과 특가!",
        createdAt: Date(),
        event: nil,
        storeInfo: nil,
        product: ProductFeedPayload(
            productName: "아오리 사과 3kg",
            description: "새콤달콤 아삭",
            imgUrl: kDummyImageURL,
            productCategoryId: StoreCategory.meat.rawValue
        ),
        reviews: sampleReviews
    ),
    Feed(
        id: DummyFeedIDs.feed4,
        storeId: DummyStoreIDs.coffeeKing,
        promoKind: .event,
        mediaType: .image,
        title: "fwjnofsd이벤트/사진",
        prompt: "ㅇㅇ러주대러주낻",
        mediaUrl: kDummyImageURL,
        body: "주더ㅜㄹ잳어ㅑㅐㅔㅈㄴ",
        createdAt: Date(),
        event: EventFeedPayload(
            eventName: "가을맞이 할인",
            description: "전 품목 10%~30%",
            imgUrl: kDummyImageURL,
            startAt: Date(),
            endAt: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ),
        storeInfo: nil,
        product: nil,
        reviews: sampleReviews
    ),
    Feed(
        id: DummyFeedIDs.feed5,
        storeId: DummyStoreIDs.breadSister,
        promoKind: .product,
        mediaType: .image,
        title: "fwfwegthge상품/사진",
        prompt: "이 상품으로 홍보문구 생성",
        mediaUrl: kDummyImageURL,
        body: "산지직송 사과 특가!",
        createdAt: Date(),
        event: nil,
        storeInfo: nil,
        product: ProductFeedPayload(
            productName: "아오리 사과 3kg",
            description: "새콤달콤 아삭",
            imgUrl: kDummyImageURL,
            productCategoryId: StoreCategory.meat.rawValue
        ),
        reviews: sampleReviews
    )
]

enum DummyReviewIDs {
    static let review1 = "R-00000000-0000-0000-0000-000000000001"
    static let review2 = "R-00000000-0000-0000-0000-000000000002"
    static let review3 = "R-00000000-0000-0000-0000-000000000003"
    static let review4 = "R-00000000-0000-0000-0000-000000000004"
    static let review5 = "R-00000000-0000-0000-0000-000000000005"
    static let review6 = "R-00000000-0000-0000-0000-000000000006"

    static let all: [String] = [review1, review2, review3, review4, review5, review6]
}
let sampleReviews: [Review] = [
    Review(
        id: DummyReviewIDs.review1,
        userId: DummyUserIDs.user1,
        feedId: DummyFeedIDs.feed1,
        content: "가격도 좋고 맛있어요!",
        imageURL: kDummyImageURL,
        rating: 5,
        createdAt: Date(),
        serverId: nil, serverUserId: nil, serverFeedId: nil
    ),
Review(
    id: DummyReviewIDs.review2,
    userId: DummyUserIDs.user2,
    feedId: DummyFeedIDs.feed1,
        content: "배송이 빨라요",
        imageURL: kDummyImageURL,
        rating: 4,
        createdAt: Date(),
        serverId: nil, serverUserId: nil, serverFeedId: nil
    )

]

struct LocalTime: Codable, Hashable, Comparable {
    var hour: Int     // 0...23
    var minute: Int   // 0...59

    init(_ hour: Int, _ minute: Int) {
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
    }

    // Date → LocalTime
    init(date: Date, calendar: Calendar = .current) {
        let c = calendar.dateComponents([.hour, .minute], from: date)
        self.init(c.hour ?? 0, c.minute ?? 0)
    }

    // LocalTime → Date (기본: 오늘 날짜에 시∙분만 세팅)
    func date(on day: Date = Date(), calendar: Calendar = .current) -> Date {
        var comps = calendar.dateComponents([.year, .month, .day], from: day)
        comps.hour = hour
        comps.minute = minute
        return calendar.date(from: comps) ?? day
    }

    // Comparable (정렬/비교용)
    static func < (lhs: LocalTime, rhs: LocalTime) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }
}

// 편의생성/파싱
extension LocalTime {
    /// "HH:mm" 또는 "H:mm" 문자열을 파싱 (예: "09:30", "9:30")
    init?(hhmm: String) {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]),
              (0...23).contains(h), (0...59).contains(m) else { return nil }
        self.init(h, m)
    }
}
