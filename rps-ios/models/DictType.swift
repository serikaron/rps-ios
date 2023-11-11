//
//  DictType.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation

private typealias SubDict = [String: String]
private typealias MainDict = [String: SubDict]

struct DictType {
    static private var dict: MainDict?
    
    static func valueOf(type: String, key: String) async -> String? {
        if dict == nil {
            await getDict()
        }
        
        return pickValue(type: type, key: key)
    }
    
    private static func pickValue(type: String, key: String) -> String? {
        guard let dict = dict,
              let subDict = dict[type]
        else { return nil }
        
        return subDict[key]
    }
    
    private static func getDict() async {
        do {
            let rsp = try await Linkman.shared.getDict()
            dict = Dictionary(uniqueKeysWithValues: rsp.map { netDict in
                (
                    netDict.dictType,
                    Dictionary(uniqueKeysWithValues: netDict.sysDictDataList.map { netDictItem in
                        (netDictItem.dictValue, netDictItem.dictLabel)
                    })
                )
            })
        } catch {
            dict = nil
        }
    }
}

extension DictType {
    static func estateType(of key: String) async -> String? {
        await valueOf(type: "fv_estate_type", key: key)
    }
}
