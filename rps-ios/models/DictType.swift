//
//  DictType.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation

private typealias SubDict = [String: String]
private typealias MainDict = [String: SubDict]

@MainActor
struct DictType {
    static private var dict: MainDict?
    static private var task: Task<Void, Never>?
    
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
            dict = rsp
                .filter { $0.dictType != nil }
                .reduce(into: MainDict()) { accumulator, currentValue in
                    accumulator[currentValue.dictType!] = currentValue.sysDictDataList
                        .filter { $0.dictValue != nil && $0.dictValue != nil }
                        .reduce(into: SubDict()) { accu, curr in
                            accu[curr.dictValue!] = curr.dictLabel!
                    }
                }
//                .map { netDict in
//                    (
//                        netDict.dictType!,
//                        Dictionary(uniqueKeysWithValues: netDict.sysDictDataList
//                            .filter { $0.dictValue != nil && $0.dictValue != nil }
//                            .map { netDictItem in
//                                (netDictItem.dictValue!, netDictItem.dictLabel!)
//                            })
//                    )
//                })
        } catch {
            dict = nil
            print("getDict error \(error)")
        }
    }
}

extension DictType {
    static func estateType(of key: String) async -> String? {
        await valueOf(type: "fv_estate_type", key: key)
    }
}
