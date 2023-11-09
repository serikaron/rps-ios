//
//  User.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

struct Account {
    static private(set) var token: String?
}

extension Account {
    static func load() {
        token = UserDefaults.token
    }
    
    static var isLoggedIn: Bool {
        token != nil
    }
    
    static func login(account: String, password: String) async throws {
        
    }
    
    static func login(phone: String, code: String) async throws {
        
    }
}

extension UserDefaults {
    static var token: String? {
        get {
            UserDefaults.rps.string(forKey: "token")
        }
        set(token) {
            UserDefaults.rps.setValue(token, forKey: "token")
        }
    }
}
