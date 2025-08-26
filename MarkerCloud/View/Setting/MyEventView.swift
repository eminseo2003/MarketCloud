//
//  MyEventView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct MyEventView: View {
    var hasEvent: Bool = true
    private var firstStore: Store? {
        dummyStores.first
    }
    var body: some View {
        VStack(spacing: 0) {
            if hasEvent {
                MyeventListView(eventList: dummyFeed)
            } else {
                NoEventView()
                    .background(Color(uiColor: .systemGray6).ignoresSafeArea())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("내 이벤트")
    }
}
