//
//  datas.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation

struct Building: Codable {
    let id: Int
    let fdCompletionDate: String?
    let fvBuildingName: String?
    let fvNameAlias: String?
    let fvFloorHeight: String?
    let fvEstateType: String?
    let fiAreaCode: Int?
    
    var completionDate: String { return fdCompletionDate ?? "" }
    var name: String { return fvBuildingName ?? "" }
    var height: String { return fvFloorHeight ?? "" }
    var alias: String { return fvNameAlias ?? "" }
    var estateType: String { return fvEstateType ?? "" }
    var areaCode: Int { return fiAreaCode ?? 0 }
}
typealias Buildings = [Building]

struct Floor: Codable {
    let name: String
    let rooms: Rooms
}

struct Floors: Codable {
    let buildingName: String
    let unitTitles: [String]
    let floors: [Floor]
    
    static var empty: Floors { Floors(buildingName: "", unitTitles: [], floors: []) }
}

struct Room: Codable {
    let name: String
    let familyRoomName: String
    let areaCode: Int
    let estateType: String
    let buildingId: Int
    let floor: String
}
typealias Rooms = [Room]

//@MainActor
struct RoomDetail {
    var networkRoomDetail: Linkman.NetworkRoomDetail
    let roomCount: Int
    
    static var empty: RoomDetail {
        RoomDetail(networkRoomDetail: .empty, roomCount: 0)
    }
    
    private let nilText: String = "无"
    
    var estateType: DictType.EstateType? {
        get { DictType.EstateType(networkRoomDetail.fvEstateType) }
        set(value) { networkRoomDetail.fvEstateType = value?.dictKey }
    }
    var estateTypeString: String? { networkRoomDetail.fvEstateType }
    
    private var dcBuilding: Linkman.DCBuilding { networkRoomDetail.dcBuilding }
    private var dcCompound: Linkman.DCCompound { networkRoomDetail.dcCompound }
    
    private var hasRoom: Bool { roomCount > 0 }
    
    var roomName: String { networkRoomDetail.fvFamilyRoomName ?? "" }
    var address: String {
        return "\(networkRoomDetail.fvProvinceName ?? "")" +
        "\(networkRoomDetail.fvCityName ?? "")" +
        "\(networkRoomDetail.fvAreaName ?? "")" +
        "\(networkRoomDetail.fvSubdistrictName ?? "")" +
        "\(networkRoomDetail.fvFamilyRoomName ?? "")"
    }
    var estateTypeText: String {
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .office:
            fallthrough
        case .landingRoom:
            fallthrough
        case .industrialSmallGarden:
            fallthrough
        case .industrialFactory:
            guard let t = networkRoomDetail.fvEstateType else { return nilText }
            return DictType.estate.label(of: t) ?? nilText
            
        case .villa:
            guard let t = dcBuilding.fvEstateType else { return nilText }
            return DictType.estate.label(of: t) ?? nilText
        case .shopStreet:
            guard let t = hasRoom ? networkRoomDetail.fvEstateType : dcBuilding.fvEstateType
            else { return nilText }
            return DictType.estate.label(of: t) ?? nilText
        case nil: return nilText
        }
    }
    var landUser: DictType.LandUser? {
        get {
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .industrialSmallGarden:
                guard let landUser = hasRoom ? networkRoomDetail.fvLandUser : dcCompound.fvLandUser
                else { return nil }
                return DictType.LandUser(rawValue: landUser)
//                return DictType.landUser.label(of: landUser) ?? nilText
            case .landingRoom:
                guard let landUser = hasRoom ? networkRoomDetail.fvLandUser : dcBuilding.fvLandUser
                else { return nil }
                return DictType.LandUser(rawValue: landUser)
//                return DictType.landUser.label(of: landUser) ?? nilText
            case .shopStreet:
                guard let landUser = dcCompound.fvLandUser else { return nil }
                return DictType.LandUser(rawValue: landUser)
//                return DictType.landUser.label(of: landUser) ?? nilText
            case .industrialFactory:
                fallthrough
            case nil:
                return nil
            }
        }
        set(value) {
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .industrialSmallGarden:
                if hasRoom {
                    networkRoomDetail.fvLandUser = value?.dictKey
                } else {
                    networkRoomDetail.dcCompound.fvLandUser = value?.dictKey
                }
            case .landingRoom:
                if hasRoom {
                    networkRoomDetail.fvLandUser = value?.dictKey
                } else {
                    networkRoomDetail.dcBuilding.fvLandUser = value?.dictKey
                }
            case .shopStreet:
                networkRoomDetail.dcCompound.fvLandUser = value?.dictKey
            case .industrialFactory:
                fallthrough
            case nil:
                break
            }
        }
    }
    var completionDate: String {
        get {
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .shopStreet:
                fallthrough
            case .industrialSmallGarden:
                return dcBuilding.fdCompletionDate ?? nilText
                
            case .landingRoom:
                return hasRoom ? networkRoomDetail.fdCompletionDate ?? nilText :
                dcBuilding.fdCompletionDate ?? nilText
                
            case .industrialFactory:
                fallthrough
            case nil: return nilText
            }
        }
        set(value) {
            networkRoomDetail.dcBuilding.fdCompletionDate = value
            networkRoomDetail.fdCompletionDate = value
        }
    }
    var position: String {
        get {
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .industrialSmallGarden:
                guard let position = networkRoomDetail.fvPosition else { return nilText }
                return hasRoom ?
                DictType.position.label(of: position) ?? nilText :
                DictType.noRoomPosition.label(of: position) ?? nilText
            case .landingRoom:
                guard let position = networkRoomDetail.fvLandingroomPosition else { return nilText }
                return hasRoom ?
                DictType.landingroomPosition.label(of: position) ?? nilText :
                DictType.noRoomPosition.label(of: position) ?? nilText
            case .shopStreet:
                guard let position = networkRoomDetail.fvShopPosition else { return nilText }
                return hasRoom ?
                DictType.shopPosition.label(of: position) ?? nilText :
                DictType.noRoomPosition.label(of: position) ?? nilText
            case .industrialFactory:
                fallthrough
            case nil: return nilText
            }
        }
        set(value) {
            networkRoomDetail.fvPosition = value
            networkRoomDetail.fvLandingroomPosition = value
            networkRoomDetail.fvShopPosition = value
        }
    }
    enum PositionType: String {
        case position, noRoomPosition, landingroomPosition, shopPosition
    }
    var positionType: PositionType {
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .industrialSmallGarden:
            return hasRoom ? .position: .noRoomPosition
        case .landingRoom:
            return hasRoom ? .landingroomPosition : .noRoomPosition
        case .shopStreet:
            return hasRoom ? .shopPosition : .noRoomPosition
        case .industrialFactory:
            fallthrough
        case nil: return .position
        }
    }
    var structure: String {
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .shopStreet:
            fallthrough
        case .industrialSmallGarden:
            guard let bs = dcBuilding.fvBuildingStructure else { return nilText }
            return DictType.buildingStructure.label(of: bs) ?? nilText
        case .landingRoom:
            guard let bs = hasRoom ? networkRoomDetail.fvBuildingStructure :
                    dcBuilding.fvBuildingStructure
            else { return nilText }
            return DictType.buildingStructure.label(of: bs) ?? nilText
        case .industrialFactory:
            fallthrough
        case nil: return nilText
        }
    }
    var facing: String {
        get {
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .landingRoom:
                fallthrough
            case .industrialSmallGarden:
                return hasRoom ?
                DictType.orientation.label(of: networkRoomDetail.fvOrientation ?? "") ?? nilText :
                DictType.buildDirection.label(of: dcBuilding.fvBuildDirection ?? "") ?? nilText
                
            case .shopStreet:
                return DictType.buildDirection.label(of: dcBuilding.fvBuildDirection ?? "") ?? nilText
                
            case .industrialFactory:
                fallthrough
            case nil: return nilText
            }
        }
        set(value) {
            networkRoomDetail.fvOrientation = value
            networkRoomDetail.dcBuilding.fvBuildDirection = value
        }
    }
    var facingType: DictType {
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .landingRoom:
            fallthrough
        case .industrialSmallGarden:
            return hasRoom ? .orientation : .buildDirection
        case .shopStreet:
            return .buildDirection
        case .industrialFactory:
            fallthrough
        case nil: return .buildDirection
        }
    }
    var height: String {
        get {
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .industrialSmallGarden:
                return "\(dcBuilding.fiLandUpperCount ?? 0)"
            case .landingRoom:
                let i = hasRoom ? networkRoomDetail.fiLandUpperCount : dcBuilding.fiLandUpperCount
                return "\(i ?? 0)"
            case .shopStreet:
                let i = dcBuilding.fiLandUpperCount
                return "\(i ?? 0)"
            case .industrialFactory:
                fallthrough
            case nil: return "0"
            }
        }
        set(value) {
            networkRoomDetail.dcBuilding.fiLandUpperCount = Int(value) ?? 0
            networkRoomDetail.fiLandUpperCount = Int(value) ?? 0
        }
    }
    var floor: String? {
        get {
            guard hasRoom else { return nil }
            switch estateType {
            case .commApartment:
                fallthrough
            case .singleApartment:
                fallthrough
            case .villa:
                fallthrough
            case .office:
                fallthrough
            case .landingRoom:
                fallthrough
            case .shopStreet:
                fallthrough
            case .industrialSmallGarden:
                return networkRoomDetail.fvInFloor ?? nilText
            case .industrialFactory:
                fallthrough
            case nil: return nilText
            }
        }
        set(value) {
            networkRoomDetail.fvInFloor = value
        }
    }
    var property: String {
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .shopStreet:
            fallthrough
        case .industrialSmallGarden:
            guard let hp = hasRoom ? networkRoomDetail.fvHouseProperty :
                    dcBuilding.fvHouseProperty
            else { return nilText }
            return DictType.houseProperty.label(of: hp) ?? nilText
            
        case .landingRoom:
            fallthrough
        case .industrialFactory:
            fallthrough
        case nil:
            return nilText
        }
    }
    var usage: String {
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .shopStreet:
            fallthrough
        case .industrialSmallGarden:
            guard let hu = hasRoom ? networkRoomDetail.fvHousingUse :
                    dcBuilding.fvHousingUse
            else { return nilText }
            return DictType.housingUse.label(of: hu) ?? nilText
        case .landingRoom:
            guard let hu = dcBuilding.fvHousingUse else { return nilText }
            return DictType.housingUse.label(of: hu) ?? nilText
        case .industrialFactory:
            fallthrough
        case nil:
            return nilText
        }
    }
    var landLevel: String {
        guard estateType == .shopStreet else { return nilText }
        return DictType.landLevel.label(of: dcCompound.fvLandLevel ?? "") ?? nilText
    }
    var landingroomUsage: String {
        guard estateType == .landingRoom else { return nilText }
        guard let lrs = hasRoom ? networkRoomDetail.fvLandingroomLandSe :
                dcBuilding.fvLandingroomLandSe
        else { return nilText }
        return DictType.landingroomLandSe.label(of: lrs) ?? nilText
    }
    
    var imageList: [String] {
        networkRoomDetail.buildingImageList.compactMap { $0.fvUrl }
        +
        networkRoomDetail.compoundImageList.compactMap { $0.fvUrl }
    }
}

struct Inquiry {
    var networkInquiry: Linkman.NetworkInquiry
    
    static var empty: Inquiry {
        Inquiry(networkInquiry: Linkman.NetworkInquiry())
    }
    
    func stringValue(of key: String, defaultValue: String? = nil) -> String? {
        networkInquiry[key] as? String ?? defaultValue
    }
    mutating func setString(_ value: String?, of key: String) {
        if let value = value {
            networkInquiry[key] = value
        } else {
            networkInquiry.removeValue(forKey: key)
        }
    }
    
    mutating func addItem(_ item: [String: Any], toList key: String) {
        var l = networkInquiry[key] as? [[String: Any]]
        if l != nil {
            l?.append(item)
        } else {
            l = [item]
        }
        networkInquiry[key] = l
    }
    
    mutating func removeItem(at idx: Int, ofList key: String) {
        guard var l = networkInquiry[key] as? [[String: Any]],
                l.count > idx
        else { return }
        l.remove(at: idx)
        networkInquiry[key] = l
    }
    
    var area: Double? {
        get { networkInquiry["fbBuildingArea"] as? Double }
        set(value) {
            networkInquiry["fbBuildingArea"] = value
        }
    }
    
    var price: String {
        networkInquiry["fvValuationPrice"] as? String ?? ""
    }
    
    var totalPrice: String {
        networkInquiry["fvValuationTotalPrice"] as? String ?? ""
    }
    
    var priceBefore: String {
        networkInquiry["fvUnitPriceBeforeAdjustment"] as? String ?? ""
    }
    
    var totalPriceBefore: String {
        networkInquiry["fvTotalPriceBeforeAdjustment"] as? String ?? ""
    }
    
    var compoundId: Int? {
        networkInquiry["fiCompoundId"] as? Int
    }
    
    var date: String {
        get { networkInquiry["fvValuationDate"] as? String ?? "" }
        set(value) {
            networkInquiry["fvValuationDate"] = value
        }
    }
    
    var fee: String {
        get { networkInquiry["fvTaxesFees"] as? String ?? "" }
        set(value) {
           networkInquiry["fvTaxesFees"] = value
        }
    }
    
    var feeRatio: String {
        get { networkInquiry["fvTaxesFeesRatio"] as? String ?? "" }
        set(value) {
            networkInquiry["fvTaxesFeesRatio"] = value
        }
    }
    
    var style: DictType.PlaneShape? {
        get {
            DictType.PlaneShape(rawValue: networkInquiry["fvStyle"] as? String)
        }
        set(value) {
            if let dictKey = value?.dictKey {
                networkInquiry["fvStyle"] = dictKey
            } else {
                networkInquiry.removeValue(forKey: "fvStyle")
            }
        }
    }
    
    var landTotalPrice: String? {
        stringValue(of: "fvLandTotalPrice")
    }
    
    var buildTotalPrice: String? {
        stringValue(of: "fvBuildTotalPrice")
    }
    
    var estateTypeString: String? { stringValue(of: "fvEstateType") }
    var estateType: DictType.EstateType? {
        get { DictType.EstateType(estateTypeString) }
        set(value) { setString(value?.dictKey, of: "fvEstateType") }
    }
    
    var decoration: DictType.LevelDecorate? {
        get {
            DictType.LevelDecorate(rawValue: networkInquiry["fvDecoreate"] as? String)
        }
        set(value) {
            if let dictKey = value?.dictKey {
                networkInquiry["fvDecoreate"] = dictKey
            } else {
                networkInquiry.removeValue(forKey: "fvDecoreate")
            }
        }
    }
    
    var decorationDate: String? {
        get {
            networkInquiry["fvDateDecorate"] as? String
        }
        set(value) {
            networkInquiry["fvDateDecorate"] = value
        }
    }
    
    var auxiliaryRoomList: [AuxiliaryRoom] {
        get {
            guard let l = networkInquiry["fvAuxiliaryRoomsAndAccessories"] as? [[String: Any]]
            else { return [] }
            return l.compactMap { room -> AuxiliaryRoom? in
                let attributeString = room["fvPropertyAttribute"] as? String
                let name = room["fvRpsPageName"] as? String
                let rights = room["fvPropertyRights"] as? String
                let unit = room["jjdw"] as? String
                
                let attribute = DictType.PropertyAttribute(mainType: attributeString, subType: name)
                let commonHas = rights == nil ? nil : DictType.CommonHas(rawValue: rights!)
                
                return AuxiliaryRoom(
                    propertyAttribute: attribute,
                    commonHas: commonHas,
                    unit: unit,
                    area: area
                )
            }
        }
    }
    
    mutating func addAuxiliaryRoom(_ room: AuxiliaryRoom) {
        var name: String?
        switch room.propertyAttribute {
        case .mainHouse:
            name = DictType.MainHouse.mian.dictKey
        case .auxiliaryHouse(let subType):
            name = subType?.dictKey
        case .appendages(let subType):
            name = subType?.dictKey
        default: break
        }
        
        let item = [
            "fvPropertyAttribute": room.propertyAttribute?.dictKey,
            "fvRpsPageName": name,
            "fvPropertyRights": room.commonHas?.dictKey,
            "jjdw": room.unit,
            "value": room.area != nil ? "\(room.area!)" : nil
        ]
        
        addItem(item, toList: "fvAuxiliaryRoomsAndAccessories")
    }
    
    mutating func removeAuxiliaryRoom(at idx: Int) {
        removeItem(at: idx, ofList: "fvAuxiliaryRoomsAndAccessories")
    }
    
    var landList: [LandIndustrialFactory] {
        get {
            guard let l = networkInquiry["landIndustrialFactoryList"] as? [[String: Any]]
            else { return [] }
            return l.map { land in
                LandIndustrialFactory(
                    name: land["landName"] as? String,
                    area: Double(land["landArea"] as? String ?? ""),
                    landUser: DictType.LandUser(rawValue: land["fvLandUser"] as? String),
                    endDate: land["fvLandEndDate"] as? String,
                    roadCondition: DictType.TemporaryRoadConditions(rawValue: land["fvTemporaryRoadConditions"] as? String)
                )
            }
        }
    }
    
    mutating func addLand(_ land: LandIndustrialFactory) {
        let land = [
            "landName": land.name,
            "landArea": land.area != nil ? "\(land.area!)" : nil,
            "fvLandUser": land.landUser?.dictKey,
            "fvLandEndDate": land.endDate,
            "fvTemporaryRoadConditions": land.roadCondition?.dictKey
        ]
        
        addItem(land, toList: "landIndustrialFactoryList")
    }
    
    mutating func removeLand(at idx: Int) {
        removeItem(at: idx, ofList: "landIndustrialFactoryList")
    }
    
    var buildingList: [BuildIndustrialFactory] {
        get {
            guard let l = networkInquiry["buildIndustrialFactoryList"] as? [[String: Any]]
            else { return [] }
            return l.map { building in
                BuildIndustrialFactory(
                    name: building["fvBuildingVarNo"] as? String,
                    area: Double(building["fbBuildingArea"] as? String ?? ""),
                    completionDate: building["fvCompletionDate"] as? String,
                    structure: DictType.BuildingStructure(rawValue: building["fvBuildingStructure"] as? String),
                    height: building["fvFloorHeight"] as? String
                )
            }
        }
    }
    
    mutating func addBuilding(_ building: BuildIndustrialFactory) {
        let building = [
            "fvBuildingVarNo": building.name,
            "fbBuildingArea": building.area != nil ? "\(building.area!)" : nil,
            "fvCompletionDate": building.completionDate,
            "fvBuildingStructure": building.structure?.dictKey,
            "fvFloorHeight": building.height
        ]
        
        addItem(building, toList: "buildIndustrialFactoryList")
    }
    
    mutating func removeBuilding(at idx: Int) {
        removeItem(at: idx, ofList: "buildIndustrialFactoryList")
    }
    
    var landUser: DictType.LandUser? {
        get { DictType.LandUser(rawValue: stringValue(of: "fvLandUser")) }
        set(value) { setString(value?.dictKey, of: "fvLandUser") }
    }
    
    var position: String? {
        get { stringValue(of: "fvPosition") }
        set(value) { setString(value, of: "fvPosition")}
    }
    
    var facing: String? {
        get { stringValue(of: "fvOrientation") }
        set(value) { setString(value, of: "fvOrientation")}
    }
    
    var floor: String? {
        get { stringValue(of: "fvInFloor") }
        set(value) { setString(value, of: "fvInFloor")}
    }
    
    var height: String? {
        get {
            if let height = networkInquiry["fiLandUpperCount"] {
                return "\(height)"
            } else {
                return nil
            }
        }
        set(value) {
            if let height = Int(value ?? "") {
                networkInquiry["fiLandUpperCount"] = height
            }
        }
    }
    
    var completionDate: String? {
        get { stringValue(of: "fdCompleteTime") }
        set(value) { setString(value, of: "fdCompleteTime") }
    }
}

struct AuxiliaryRoom {
    var propertyAttribute: DictType.PropertyAttribute? {
        didSet {
            switch propertyAttribute {
            case .mainHouse:
                unit = "m²"
            case .auxiliaryHouse(let subType):
                if let subType = subType,
                   subType.label.contains("车") {
                    unit = "个"
                } else {
                    unit = "m²"
                }
            case .appendages(let subType):
                if let subType = subType,
                   subType.label.contains("车") {
                    unit = "个"
                } else {
                    unit = "m²"
                }
            default:
                unit = "m²"
            }
        }
    }
    var commonHas: DictType.CommonHas?
    var unit: String?
    var area: Double?
}

struct LandIndustrialFactory {
    var name: String?
    var area: Double?
    var landUser: DictType.LandUser?
    var endDate: String?
    var landSe: DictType.LandSe?
    var roadCondition: DictType.TemporaryRoadConditions?
}

struct BuildIndustrialFactory {
    var name: String?
    var area: Double?
    var completionDate: String?
    var structure: DictType.BuildingStructure?
    var height: String?
}

struct ReferenceCase {
    let source: String
    let date: String
    let address: String
    let decorate: String
    let floor: String
    let price: String
    let totalPrice: String
    let area: String
}
