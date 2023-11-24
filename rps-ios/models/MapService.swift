//
//  MapService.swift
//  rps-ios
//
//  Created by serika on 2023/11/24.
//

import Foundation
import AMapFoundationKit
import MAMapKit

class MapService: ObservableObject {
    static func initMAMapKit() {
        AMapServices.shared().apiKey = "8bb671a8252449b2d2a692f04ff708cc"
        AMapServices.shared().enableHTTPS = true
        MAMapView.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        MAMapView.updatePrivacyAgree(.didAgree)
    }
}
