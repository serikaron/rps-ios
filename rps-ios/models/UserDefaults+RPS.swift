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
            let id = UserDefaults.rps.integer(forKey: "account.id")
            guard hasAccount,
                  id != 0,
                  let nickname = UserDefaults.rps.string(forKey: "account.nickname"),
                  let phone = UserDefaults.rps.string(forKey: "account.phone"),
                  let organ = UserDefaults.rps.string(forKey: "account.organ"),
                  let unit = UserDefaults.rps.string(forKey: "account.unit"),
                  let clientName = UserDefaults.rps.string(forKey: "account.clientName"),
                  let position = UserDefaults.rps.string(forKey: "account.position"),
                  let status = UserDefaults.rps.string(forKey: "account.status"),
                  let date = UserDefaults.rps.string(forKey: "account.date"),
                  let gender = UserDefaults.rps.string(forKey: "account.gender"),
                  let birthday = UserDefaults.rps.string(forKey: "account.birthday"),
                  let email = UserDefaults.rps.string(forKey: "account.email"),
                  let workPhone = UserDefaults.rps.string(forKey: "account.workPhone"),
                  let permissions = UserDefaults.rps.array(forKey: "account.permissions") as? [String]
            else { return nil }
            
            let orgId = UserDefaults.rps.integer(forKey: "account.orgId")
            let unitId = UserDefaults.rps.integer(forKey: "account.unitId")
            return Account(
                id: id, orgId: orgId, unitId: unitId, nickname: nickname,
                phone: phone, placeOrganization: organ, placeUnit: unit,
                clientName: clientName, position: position,
                status: DictType.CommonStatus(rawValue: status) ?? ._0,
                date: date, gender: Gender(rawValue: gender) ?? .male,
                birthday: birthday, email: email, workPhone: workPhone,
                permissions: permissions
            )
        }
        set(account) {
            if account == nil {
                UserDefaults.rps.setValue(false, forKey: "account.has")
                UserDefaults.rps.removeObject(forKey: "account.id")
                UserDefaults.rps.removeObject(forKey: "account.orgId")
                UserDefaults.rps.removeObject(forKey: "account.unitId")
                UserDefaults.rps.removeObject(forKey: "account.nickname")
                UserDefaults.rps.removeObject(forKey: "account.phone")
                UserDefaults.rps.removeObject(forKey: "account.unit")
                UserDefaults.rps.removeObject(forKey: "account.clientName")
                UserDefaults.rps.removeObject(forKey: "account.position")
                UserDefaults.rps.removeObject(forKey: "account.status")
                UserDefaults.rps.removeObject(forKey: "account.date")
                UserDefaults.rps.removeObject(forKey: "account.gender")
                UserDefaults.rps.removeObject(forKey: "account.birthday")
                UserDefaults.rps.removeObject(forKey: "account.email")
                UserDefaults.rps.removeObject(forKey: "account.workPhone")
                UserDefaults.rps.removeObject(forKey: "account.permissions")
            } else {
                UserDefaults.rps.setValue(true, forKey: "account.has")
                UserDefaults.rps.setValue(account!.id, forKey: "account.id")
                UserDefaults.rps.setValue(account!.orgId, forKey: "account.orgId")
                UserDefaults.rps.setValue(account!.unitId, forKey: "account.unitId")
                UserDefaults.rps.setValue(account!.nickname, forKey: "account.nickname")
                UserDefaults.rps.setValue(account!.phone, forKey: "account.phone")
                UserDefaults.rps.setValue(account!.placeUnit, forKey: "account.unit")
                UserDefaults.rps.setValue(account!.placeOrganization, forKey: "account.organ")
                UserDefaults.rps.setValue(account!.clientName, forKey: "account.clientName")
                UserDefaults.rps.setValue(account!.position, forKey: "account.position")
                UserDefaults.rps.setValue(account!.status.dictKey, forKey: "account.status")
                UserDefaults.rps.setValue(account!.date, forKey: "account.date")
                UserDefaults.rps.setValue(account!.gender.dictKey, forKey: "account.gender")
                UserDefaults.rps.setValue(account!.birthday, forKey: "account.birthday")
                UserDefaults.rps.setValue(account!.email, forKey: "account.email")
                UserDefaults.rps.setValue(account!.workPhone, forKey: "account.workPhone")
                UserDefaults.rps.setValue(account!.permissions, forKey: "account.permissions")
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
