//
//  images+.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

extension Image {
    enum main {
        static var searchIcon: Image { return Image("search-icon") }
        static var arrowIcon: Image { return Image("arrow-icon") }
        static var indexTabIcon: Image { return Image("index-tab") }
        static var recordTabIcon: Image { return Image("record-tab") }
        static var csTabIcon: Image { return Image("cs-tab") }
        static var meTabIcon: Image { return Image("me-tab") }
        static var indexTabIconSelected: Image { return Image("index-tab-selected") }
        static var recordTabIconSelected: Image { return Image("record-tab-selected") }
        static var csTabIconSelected: Image { return Image("cs-tab-selected") }
        static var meTabIconSelected: Image { return Image("me-tab-selected") }
        static var placeholder: Image { return Image("image-placeholder") }
    }
    
    enum index {
        static var announceIcon: Image { return Image("index-announce-icon") }
        static var buttonBg: Image { return Image("index-button-bg") }
        static var inquiryIcon: Image { return Image("index-inquiry-icon") }
        static var commissionIcon: Image { return Image("index-commission-icon") }
        static var searchGIS: Image { return Image("index-search-gis") }
        static var searchOCR: Image { return Image("index-search-ocr") }
        static var editIcon: Image { return Image("index-edit") }
        static var pointIcon: Image { return Image("index-point") }
        static var close: Image { return Image("index-room-close") }
        static var mapIcon: Image { return Image("index-map-icon") }
    }
    
    enum onboarding {
        static var background: Image { return Image("onboarding-background") }
        static var logo: Image { return Image("onboarding-logo") }
        static var accountIcon: Image { return Image("onboarding-account") }
        static var passwordIcon: Image { return Image("onboarding-password") }
        static var phoneIcon: Image { return Image("onboarding-phone") }
        static var codeIcon: Image { return Image("onboarding-code") }
        static var selectedIcon: Image { return Image("onboarding-selected") }
        static var deselectedIcon: Image { return Image("onboarding-deselected") }
    }
}
