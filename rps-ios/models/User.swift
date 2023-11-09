//
//  User.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

struct User {
    static private(set) var token: String?
}

extension User {
    static func
    static func isLoggedIn() -> Bool {
        token = UserDefaults.token
        return token != nil
    }
}

private extension UserDefaults {
    static var token: String? {
        get {
            UserDefaults.rps.string(forKey: "token")
        }
        set(token) {
            UserDefaults.rps.setValue(token, forKey: "token")
        }
    }
}
