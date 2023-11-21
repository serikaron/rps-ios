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
            let hasAccount = UserDefaults.rps.bool(forKey: "account.has")
            guard hasAccount,
                  let nickname = UserDefaults.rps.string(forKey: "account.nickname"),
                  let phone = UserDefaults.rps.string(forKey: "account.phone"),
                  let organ = UserDefaults.rps.string(forKey: "account.organ"),
                  let unit = UserDefaults.rps.string(forKey: "account.unit")
            else { return nil }
            
            let orgId = UserDefaults.rps.integer(forKey: "account.orgId")
            let unitId = UserDefaults.rps.integer(forKey: "account.unitId")
            return Account(
                id: 0, orgId: orgId, unitId: unitId, nickname: nickname,
                phone: phone, placeOrganization: organ, placeUnit: unit
            )
        }
        set(account) {
            if account == nil {
                UserDefaults.rps.setValue(false, forKey: "account.has")
                UserDefaults.rps.removeObject(forKey: "account.orgId")
                UserDefaults.rps.removeObject(forKey: "account.unitId")
                UserDefaults.rps.removeObject(forKey: "account.nickname")
                UserDefaults.rps.removeObject(forKey: "account.phone")
                UserDefaults.rps.removeObject(forKey: "account.unit")
                UserDefaults.rps.removeObject(forKey: "account.organ")
            } else {
                UserDefaults.rps.setValue(true, forKey: "account.has")
                UserDefaults.rps.setValue(account!.orgId, forKey: "account.orgId")
                UserDefaults.rps.setValue(account!.unitId, forKey: "account.unitId")
                UserDefaults.rps.setValue(account!.nickname, forKey: "account.nickname")
                UserDefaults.rps.setValue(account!.phone, forKey: "account.phone")
                UserDefaults.rps.setValue(account!.placeUnit, forKey: "account.unit")
                UserDefaults.rps.setValue(account!.placeOrganization, forKey: "account.organ")
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
