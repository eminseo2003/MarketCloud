//
//  KakaoUser.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import Foundation
import SwiftUI

struct User: Identifiable {
    let id: String
    let password: String
    let name: String
    let email: String?
    let createdAt: Date
    let imgUrl: URL

    init(id: String,
         password: String,
         name: String,
         email: String?,
         createdAt: Date,
         imgUrl: URL) {
        self.id = id
        self.password = password
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.imgUrl = imgUrl
    }
}


