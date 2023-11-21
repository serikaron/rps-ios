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
    
    case estate, orientation, buildDirection, landUser, buildingStructure, houseProperty, housingUse, landingroomLandSe, position, noRoomPosition, shopPosition, landingroomPosition, landLevel, planeShape, levelDecorate, propertyAttribute, mainHouse, auxiliaryHouse, appendages
    case common_has, fv_land_se, fv_temporary_road_conditions, fi_trade_type, fv_decoration, fv_type_of_house, fv_daylighting, fv_noise, fv_landscape, fv_garden, fv_terrace, fv_attic, fv_basement, valuation_purpose, fv_co_ownership_situation, fv_report_spatial_layout
    
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
        case .noRoomPosition: return "no_room_position"
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

protocol HasLabel {
    var label: String { get }
}

extension DictType {
    enum PropertyAttribute: Hashable {
        case mainHouse
        case auxiliaryHouse(subType: AuxiliaryHouse?)
        case appendages(subType: Appendages?)
        
        init?(mainType: String?, subType: String?) {
            switch mainType {
            case "main_house": self = .mainHouse
            case "auxiliary_house":
                let subType = subType == nil ? nil : AuxiliaryHouse(rawValue: subType!)
                self = .auxiliaryHouse(subType: subType)
            case "appendages":
                let subType = subType == nil ? nil : Appendages(rawValue: subType!)
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

    enum LevelDecorate: CaseIterable, HasLabel {
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

    enum EstateType: String, CaseIterable, HasLabel {
        case commApartment, singleApartment, villa, office, landingRoom, shopStreet, industrialSmallGarden, industrialFactory
        
        init?(_ value: String?) {
            switch value {
            case "commApartment": self = .commApartment
            case "singleApartment": self = .singleApartment
            case "villa": self = .villa
            case "office": self = .office
            case "landingRoom": self = .landingRoom
            case "shopStreet": self = .shopStreet
            case "industrialSmallGarden": self = .industrialSmallGarden
            case "industrialFactory": self = .industrialFactory
            default: return nil
            }
        }
        
        var dictKey: String { rawValue }
        var label: String { DictType.estate.label(of: dictKey) ?? "" }
    }

    enum LandUser: CaseIterable, HasLabel {
        case _1, _2, _3
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            }
        }
        
        var label: String { DictType.landUser.label(of: dictKey) ?? "" }
    }
    
    enum LandSe: CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            }
        }
        
        var label: String { DictType.fv_land_se.label(of: dictKey) ?? "" }
    }
    
    enum TemporaryRoadConditions: CaseIterable {
        case _1, _2, _3, _4, _5, _6
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            }
        }
        
        var label: String { DictType.fv_temporary_road_conditions.label(of: dictKey) ?? "" }
    }
    
    enum BuildingStructure: CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5, _6, _7, _8
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            case "7": self = ._7
            case "8": self = ._8
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            case ._7: return "7"
            case ._8: return "8"
            }
        }

        var label: String { DictType.buildingStructure.label(of: dictKey) ?? "" }
    }
    
    enum Position: CaseIterable {
        case _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            case "7": self = ._7
            case "8": self = ._8
            case "9": self = ._9
            case "10": self = ._10
            case "11": self = ._11
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            case ._7: return "7"
            case ._8: return "8"
            case ._9: return "9"
            case ._10: return "10"
            case ._11: return "11"
            }
        }

        var label: String { DictType.position.label(of: dictKey) ?? "" }
    }
    
    enum NoRoomPosition: CaseIterable {
        case _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            case "7": self = ._7
            case "8": self = ._8
            case "9": self = ._9
            case "10": self = ._10
            case "11": self = ._11
            case "12": self = ._12
            case "13": self = ._13
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            case ._7: return "7"
            case ._8: return "8"
            case ._9: return "9"
            case ._10: return "10"
            case ._11: return "11"
            case ._12: return "12"
            case ._13: return "13"
            }
        }

        var label: String { DictType.noRoomPosition.label(of: dictKey) ?? "" }
    }
    
    enum LandingroomPosition: CaseIterable {
        case _1, _2, _3, _4, _5
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            }
        }

        var label: String { DictType.landingroomPosition.label(of: dictKey) ?? "" }
    }
    
    enum ShopPosition: CaseIterable {
        case _1, _2, _3, _4, _5, _6
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            }
        }

        var label: String { DictType.shopPosition.label(of: dictKey) ?? "" }
    }
    
    enum Orientation: CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5, _6, _7, _8, _9
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            case "7": self = ._7
            case "8": self = ._8
            case "9": self = ._9
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            case ._7: return "7"
            case ._8: return "8"
            case ._9: return "9"
            }
        }

        var label: String { DictType.orientation.label(of: dictKey) ?? "" }
    }
    
    enum BuildDirection: CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5, _6, _7, _8
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            case "7": self = ._7
            case "8": self = ._8
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            case ._7: return "7"
            case ._8: return "8"
            }
        }

        var label: String { DictType.buildDirection.label(of: dictKey) ?? "" }
    }
    
    enum TradeType: CaseIterable {
        case _1, _2, _3
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            }
        }

        var label: String { DictType.fi_trade_type.label(of: dictKey) ?? "" }
    }
    
    enum Decoration: CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5, _6, _7
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            case "7": self = ._7
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            case ._7: return "7"
            }
        }

        var label: String { DictType.fv_decoration.label(of: dictKey) ?? "" }
    }

    enum ValuationPurpose: String, CaseIterable, HasLabel {
        case mortgageLoanLoanValuation, realEstateInsuranceValuation, realEstateDemolitionAndResettlementValuation, valuationOfCompensationForRealEstateDemolition, realEstateSegmentationAndConsolidationValuation, realEstateTransactionTaxValuation, realEstateDisputeValuation, realEstateFeasibilityStudy, realEstateAuctionLowPriceValuation, realEstateJudicialAppraisalIncludingDecorationValuation, realEstateJudicialAppraisalAndValuation, realEstateReplacementValuation, valuationOfRealEstateTransferPrice, realEstateTransferAndLoanValuation, realEstateRentalPriceValuation, otherPurposesOfRealEstateValuationAndEquityValuation
        
        var dictKey: String { rawValue }
        var label: String { DictType.valuation_purpose.label(of: dictKey) ?? "" }
    }
    
    enum HousingUse: String, CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5, _6
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            case "4": self = ._4
            case "5": self = ._5
            case "6": self = ._6
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            case ._4: return "4"
            case ._5: return "5"
            case ._6: return "6"
            }
        }

        var label: String { DictType.housingUse.label(of: dictKey) ?? "" }
    }
    
    enum CoOwnershipSituation: String, CaseIterable, HasLabel {
        case _1, _2, _3
        
        init?(rawValue: String?) {
            switch rawValue {
            case "1": self = ._1
            case "2": self = ._2
            case "3": self = ._3
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "1"
            case ._2: return "2"
            case ._3: return "3"
            }
        }

        var label: String { DictType.fv_co_ownership_situation.label(of: dictKey) ?? "" }
    }
    
    enum SpatialLayout: CaseIterable, HasLabel {
        case _1, _2, _3, _4, _5
        
        init?(rawValue: String?) {
            switch rawValue {
            case "合理": self = ._1
            case "较合理": self = ._2
            case "一般": self = ._3
            case "较差": self = ._4
            case "差": self = ._5
            default: return nil
            }
        }
        
        var dictKey: String {
            switch self {
            case ._1: return "合理"
            case ._2: return "较合理"
            case ._3: return "一般"
            case ._4: return "较差"
            case ._5: return "差"
            }
        }

        var label: String { DictType.fv_report_spatial_layout.label(of: dictKey) ?? "" }
    }
}
