//
//  TabService.swift
//  rps-ios
//
//  Created by serika on 2023/11/22.
//

import Foundation

enum MainTabPage: CaseIterable {
    case index, record, cs, me
}

class TabService: ObservableObject {
    @Published var selectedTab: MainTabPage = .index
    @Published var isHidden = false
    
    static var height: CGFloat = 49 + 34
}
