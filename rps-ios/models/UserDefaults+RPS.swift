//
//  UserDefault+RPS.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

extension UserDefaults {
    static var rps: UserDefaults = {
        UserDefaults.init(suiteName: "rps")!
    }()
}
