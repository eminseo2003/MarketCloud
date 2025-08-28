//
//  StoreDetail.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import SwiftUI

class StoreDetail: ObservableObject {
    @Published var businessType: String = ""
    @Published var phoneNumber: String = ""
    @Published var weekdayOpen: Date = Date()
    @Published var weekdayClose: Date = Date()
    @Published var weekendOpen: Date = Date()
    @Published var weekendClose: Date = Date()
    @Published var roadAddress: String = ""
    @Published var jibunAddress: String = ""
    @Published var usesVouchers: [String] = []
    @Published var storeDescription: String = ""
}
