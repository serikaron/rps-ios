//
//  TabService.swift
//  rps-ios
//
//  Created by serika on 2023/11/22.
//

import Foundation

enum MainTabPage: CaseIterable {
    case index, record, cs
}

class TabService: ObservableObject {
    @Published var selectedTab: MainTabPage = .index
}
