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

    static var token: String? {
        get {
            let out = UserDefaults.rps.string(forKey: "token")
            print("load token: \(out)")
            return out
        }
        set(token) {
            print("save token: \(token)")
            UserDefaults.rps.setValue(token, forKey: "token")
        }
    }
}
