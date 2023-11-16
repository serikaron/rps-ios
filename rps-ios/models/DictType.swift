//
//  DictType.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation


enum DictType: String {
    typealias SubDict = [String: String]
    typealias MainDict = [String: SubDict]
    
    case estate, orientation, buildDirection, landUser, buildingStructure, houseProperty, housingUse, landingroomLandSe, position, noRoomPositon, shopPosition, landingroomPosition, landLevel, planeShape, levelDecorate, propertyAttribute, mainHouse, auxiliaryHouse, appendages, common_has
    
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
        case .planeShape: return "fv_plane_shape"
        case .levelDecorate: return "fv_level_decorate_fk"
        case .propertyAttribute: return "fv_property_attribute"
        case .mainHouse: return "main_house"
        case .auxiliaryHouse: return "auxiliary_house"
        case .appendages: return "appendages"
        default:
            return rawValue
        }
    }
}

extension DictType {
    static private var dict: MainDict? {
        didSet { UserDefaults.dictType = dict }
    }
    
    static private var task: Task<Void, Never>?
    
    static func valueOf(type: String, key: String) async -> String? {
        if dict == nil {
            await getDict()
        }
        
        return pickValue(type: type, key: key)
    }
    
    fileprivate static func pickValue(type: String, key: String) -> String? {
        if dict == nil {
            dict = UserDefaults.dictType
        }
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

extension DictType {
    enum PropertyAttribute: Hashable {
        case mainHouse
        case auxiliaryHouse(subType: AuxiliaryHouse?)
        case appendages(subType: Appendages?)
        
        init?(mainType: String, subType: String) {
            switch mainType {
            case "main_house": self = .mainHouse
            case "auxiliary_house":
                guard let subType = AuxiliaryHouse(rawValue: subType) else { return nil }
                self = .auxiliaryHouse(subType: subType)
            case "appendages":
                guard let subType = Appendages(rawValue: subType) else { return nil }
                self = .appendages(subType: subType)
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case .mainHouse:
                return "main_house"
            case .auxiliaryHouse:
                return "auxiliary_house"
            case .appendages:
                return "appendages"
            }
        }
        var label: String { DictType.propertyAttribute.label(of: dictKey) ?? "" }
    }
    
    enum MainHouse: String, CaseIterable {
        case mian
        
        var dictKey: String { rawValue }
        var label: String { DictType.mainHouse.label(of: dictKey) ?? "" }
    }
    
    enum AuxiliaryHouse: String, CaseIterable {
        case garden, terrace, attic, basement
        
        var dictKey: String { rawValue }
        var label: String {
            DictType.auxiliaryHouse.label(of: dictKey) ?? ""
        }
    }
    
    enum Appendages: String, CaseIterable {
        case attic, main_room, jump_layer, sheds, automatic_garage, storeroom, ground_garage, stilt_floor, ground_vehicles, underground_car, theunderground_garage, basement, terrace
        
        var dictKey: String { rawValue }
        var label: String { DictType.appendages.label(of: dictKey) ?? "" }
    }
    
    enum CommonHas: CaseIterable {
        case has, not
        init?(rawValue: String) {
            switch rawValue {
            case "0": self = .not
            case "1": self = .has
            default: return nil
            }
        }
        var dictKey: String {
            switch self {
            case .has:
                return "1"
            case .not:
                return "0"
            }
        }
        var label: String { DictType.common_has.label(of: dictKey) ?? "" }
    }
    
    enum PlaneShape: CaseIterable, Hashable {
        case good, aboveAverage, average, belowAverage, poor
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = .average
            case "2": self = .aboveAverage
            case "3": self = .good
            case "4": self = .belowAverage
            case "5": self = .poor
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case .good:
                return "3"
            case .aboveAverage:
                return "2"
            case .average:
                return "1"
            case .belowAverage:
                return "4"
            case .poor:
                return "5"
            }
        }
        
        var label: String {
            DictType.planeShape.label(of: dictKey) ?? ""
        }
    }

    enum LevelDecorate: CaseIterable {
        case raw, simple, medium, heigh, grand
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = .raw
            case "2": self = .simple
            case "3": self = .medium
            case "4": self = .heigh
            case "5": self = .grand
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case .raw:
                return "1"
            case .simple:
                return "2"
            case .medium:
                return "3"
            case .heigh:
                return "4"
            case .grand:
                return "5"
            }
        }
        
        var label: String { DictType.levelDecorate.label(of: dictKey) ?? "" }
    }

}
