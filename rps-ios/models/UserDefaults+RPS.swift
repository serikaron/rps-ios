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
    
    static var dictType1: DictType.MainDict? {
        get {
            guard let allKeys = UserDefaults.rps.stringArray(forKey: "dictType.mainDict.keys"),
                  !allKeys.isEmpty
            else { return nil }
            
            var out = DictType.MainDict()
            
            allKeys.forEach { mainKey in
                guard let allSubKeys = UserDefaults.rps.stringArray(forKey: "dictType.\(mainKey).subDict.keys"),
                      !allSubKeys.isEmpty
                else { return }
                
                var subDict = DictType.SubDict()
                allSubKeys.forEach { subKey in
                    guard let value = UserDefaults.rps.string(forKey: "dictType.\(mainKey).\(subKey)")
                    else { return }
                    subDict[subKey] = value
                }
                out[mainKey] = subDict
            }
            
            return out
        }
        
        set(value) {
            if let mainDict = value {
                mainDict.forEach { (mainKey, subDict) in
                    subDict.forEach { (subKey, value) in
                        UserDefaults.rps.setValue(value, forKey: "dictType.\(mainKey).\(subKey)")
                    }
                    
                    UserDefaults.rps.setValue(subDict.keys, forKey: "dictType.\(mainKey).subDict.keys")
                }
                UserDefaults.rps.setValue(mainDict.keys, forKey: "dictType.mainDict.keys")
            } else {
                if let allKeys = UserDefaults.rps.stringArray(forKey: "dictType.mainDict.keys"),
                   !allKeys.isEmpty {
                    
                    allKeys.forEach { mainKey in
                        guard let allSubKeys = UserDefaults.rps.stringArray(forKey: "dictType.\(mainKey).subDict.keys"),
                              !allSubKeys.isEmpty
                        else { return }
                        
                        allSubKeys.forEach { subKey in
                            UserDefaults.rps.removeObject(forKey: "dictType.\(mainKey).\(subKey)")
                        }
                        
                        UserDefaults.rps.removeObject(forKey: "dictType.\(mainKey).subDict.keys")
                    }
                    UserDefaults.rps.removeObject(forKey: "dictType.mainDict.keys")
                }
            }
        }
    }
}
