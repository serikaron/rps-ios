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
    }
    
    enum index {
        static var announceIcon: Image { return Image("index-announce-icon") }
        static var buttonBg: Image { return Image("index-button-bg") }
        static var inquiryIcon: Image { return Image("index-inquiry-icon") }
        static var commissionIcon: Image { return Image("index-commission-icon") }
        static var searchGIS: Image { return Image("index-search-gis") }
        static var searchOCR: Image { return Image("index-search-ocr") }
    }
}
