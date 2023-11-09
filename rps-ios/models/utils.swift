//
//  utils.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

enum Gender {
    case male, female
    var text: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        }
    }
}
