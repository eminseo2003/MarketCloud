//
//  MyEventView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

struct MyEventView: View {
    var hasEvent: Bool = true
    var filteredEvents: [Feed] {
        dummyFeed
            .filter { $0.promoKind == .event }
    }
    var body: some View {
        VStack(spacing: 0) {
            if hasEvent {
                MyeventListView(eventList: filteredEvents)
            } else {
                NoEventView()
                    .background(Color(uiColor: .systemGray6).ignoresSafeArea())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("내 이벤트")
    }
}
