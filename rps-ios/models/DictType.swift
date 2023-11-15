//
//  DictType.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation

private typealias SubDict = [String: String]
private typealias MainDict = [String: SubDict]

enum DictType {
    case estate, orientation, buildDirection, landUser, buildingStructure, houseProperty, housingUse, landingroomLandSe,
    position, noRoomPositon, shopPosition, landingroomPosition, landLevel
    
    var typeName: String {
        switch self {
        case .estate: return "fv_estate_type"
        case .orientation: return "fv_orientation"
        case .landUser: return "fv_land_user"
        case .buildingStructure: return "fv_building_structure"
        case .houseProperty: return "fv_house_property"
        case .housingUse: return "fv_housing_use"
        case .landingroomLandSe: return "fv_landingroom_land_se"
        case .position: return "fv_position"
        case .noRoomPositon: return "no_room_position"
        case .shopPosition: return "fv_shop_position"
        case .landingroomPosition: return "fv_landingroom_position"
        case .buildDirection: return "fv_build_direction"
        case .landLevel: return "fv_land_level"
        }
    }
}

extension DictType {
    static private var dict: MainDict?
    static private var task: Task<Void, Never>?
    
    static func valueOf(type: String, key: String) async -> String? {
        if dict == nil {
            await getDict()
        }
        
        return pickValue(type: type, key: key)
    }
    
    fileprivate static func pickValue(type: String, key: String) -> String? {
        guard let dict = dict,
              let subDict = dict[type]
        else { return nil }
        
        return subDict[key]
    }
    
    static func getDict() async {
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
    
    func asyncLabel(of key: String) async -> String? {
        await Self.valueOf(type: typeName, key: key)
    }
    
    func label(of key: String) -> String? {
        Self.pickValue(type: typeName, key: key)
    }
}

//extension DictType {
//    static func estateType(of key: String) async -> String? {
//        await valueOf(type: "fv_estate_type", key: key)
//    }
//    
//    static func estateTypeSync(of key: String) -> String? {
//        pickValue(type: "fv_estate_type", key: key)
//    }
//}
