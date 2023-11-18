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
            return out
        }
        set(token) {
            UserDefaults.rps.setValue(token, forKey: "token")
        }
    }
    
    static var account: Account? {
        get {
            let orgId = UserDefaults.rps.integer(forKey: "account.orgId")
            return Account(id: 0, orgId: orgId)
        }
        set(account) {
            if account == nil {
                UserDefaults.rps.removeObject(forKey: "account.orgId")
            } else {
                UserDefaults.rps.setValue(account!.orgId, forKey: "account.orgId")
            }
        }
    }
    
    static var dictType: DictType.MainDict? {
        get {
            UserDefaults.rps.value(forKey: "dictType") as? DictType.MainDict
        }
        set(value) {
            if value == nil {
                UserDefaults.rps.removeObject(forKey: "dictType")
            } else {
                UserDefaults.rps.setValue(value, forKey: "dictType")
            }
        }
    }
}
