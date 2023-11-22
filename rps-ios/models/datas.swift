//
//  datas.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation
import UIKit

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
    
    var id: String {
        networkRoomDetail.id ?? ""
    }
    
    static var empty: RoomDetail {
        RoomDetail(networkRoomDetail: .empty, roomCount: 0)
    }
    
    private let nilText: String = "无"
    
    var estateType: DictType.EstateType? {
        get { DictType.EstateType(networkRoomDetail.fvEstateType) }
        set(value) { networkRoomDetail.fvEstateType = value?.dictKey }
    }
    var estateTypeString: String? { networkRoomDetail.fvEstateType }
    var estateTypeLabel: String { estateType?.label ?? "" }
    
    private var dcBuilding: Linkman.DCBuilding { networkRoomDetail.dcBuilding }
    private var dcCompound: Linkman.DCCompound { networkRoomDetail.dcCompound }
    
    var hasRoom: Bool { roomCount > 0 }
    
    var roomName: String { networkRoomDetail.fvFamilyRoomName ?? "" }
    var address: String {
        return "\(networkRoomDetail.fvProvinceName ?? "")" +
        "\(networkRoomDetail.fvCityName ?? "")" +
        "\(networkRoomDetail.fvAreaName ?? "")" +
        "\(networkRoomDetail.fvSubdistrictName ?? "")" +
        "\(networkRoomDetail.fvFamilyRoomName ?? "")"
    }
    var compoundName: String { 
        get { networkRoomDetail.fvCompoundName ?? "" }
        set(value) { networkRoomDetail.fvCompoundName = value}
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
    var wuYeFenLei: String {
        get { networkRoomDetail.wuYeFenLei ?? "" }
        set(value) { networkRoomDetail.wuYeFenLei = value }
    }
    var compoundId: Int {
        get { networkRoomDetail.fiCompoundId ?? 0 }
        set(value) { networkRoomDetail.fiCompoundId = value }
    }
    var areaName: String {
        get { networkRoomDetail.fvAreaName ?? "" }
        set(value) { networkRoomDetail.fvAreaName = value }
    }
    var specialCircumstances: String { networkRoomDetail.fvSpecialCircumstances ?? "" }
    var buildingSpecialCircumstances: String { dcBuilding.fvSpecialCircumstances ?? "" }
    var compoundSpecialCircumstances: String { dcCompound.fvSpecialCircumstances ?? "" }
    var typeOfHouse: String { DictType.fv_type_of_house.label(of: networkRoomDetail.fvTypeOfHouse ?? "") ?? "" }
    var daylighting: String { DictType.fv_daylighting.label(of: networkRoomDetail.fvDaylighting ?? "" ) ?? "" }
    var noise: String { DictType.fv_noise.label(of: networkRoomDetail.fvNoise ?? "" ) ?? "" }
    var decoration: String { DictType.fv_decoration.label(of: networkRoomDetail.fvdecoration ?? "" ) ?? "" }
    var landscape: String { DictType.fv_landscape.label(of: networkRoomDetail.fv_landscape ?? "" ) ?? "" }
    var garden: String { DictType.fv_garden.label(of: networkRoomDetail.fv_garden ?? "" ) ?? "" }
    var terrace: String { DictType.fv_terrace.label(of: networkRoomDetail.fv_terrace ?? "" ) ?? "" }
    var attic: String { DictType.fv_attic.label(of: networkRoomDetail.fv_attic ?? "" ) ?? "" }
    var basement: String { DictType.fv_basement.label(of: networkRoomDetail.fv_basement ?? "" ) ?? "" }
    var compoundProperty: String { DictType.houseProperty.label(of: dcCompound.fvHouseProperty ?? "") ?? "" }
    var compoundCompletionDate: String { dcCompound.fvCompletionDate ?? "" }
    var compoundDeveloper: String { dcCompound.fvDeveloper ?? "" }
    var compoundConstruction: String { dcCompound.fvConstruction ?? "" }
    var compoundSaleCompany: String { dcCompound.fvSaleCompany ?? "" }
    var compoundSaleAddress: String { dcCompound.fvSaleAddress ?? "" }
    var compoundSalePhoneno: String { dcCompound.fvSalePhoneno ?? "" }
    var compoundSaleTime: String { dcCompound.fvSaleTime ?? "" }
    var compoundCityName: String { dcCompound.fvCityName ?? "" }
    var compoundAreaName: String { dcCompound.fvAreaName ?? "" }
    var compoundSubdistrictName: String { dcCompound.fvSubdistrictName ?? "" }
    var compoundCompoundName: String { dcCompound.fvCompoundName ?? "" }
    var compoundLandAreaString: String { "\(dcCompound.fbLandArea ?? 0)" }
    var compoundLandUserLabel: String { DictType.landUser.label(of: dcCompound.fvLandUser ?? "") ?? "" }
    var compoundLandLevelLabel: String { DictType.landUser.label(of: dcCompound.fvLandLevel ?? "") ?? "" }
    var compoundToEast: String { dcCompound.fvToEast ?? "" }
    var compoundToWest: String { dcCompound.fvToWest ?? "" }
    var compoundToSouth: String { dcCompound.fvToSouth ?? "" }
    var compoundToNorth: String { dcCompound.fvToNorth ?? "" }
    var compoundBusLine: String { dcCompound.fvBusLineName ?? "" }
    var compoundFastBus: String { dcCompound.fvFastBus ?? "" }
    var compoundSubway: String { dcCompound.fvSubwayName ?? "" }
    var compoundVegeMarket: String { dcCompound.fvVegeMarket ?? "" }
    var compoundBusinessSet: String { dcCompound.fvBusinessSet ?? "" }
    var compoundHospital: String { dcCompound.fvHospital ?? "" }
    var compoundFinaceOrg: String { dcCompound.fvFinaceOrg ?? "" }
    var compoundStadium: String { dcCompound.fvStadium ?? "" }
    var compoundRelaxSquare: String { dcCompound.fvRelaxSquare ?? ""}
    var compoundKindergarten: String { dcCompound.fvKindergarten ?? ""}
    var compoundPrimarySchool: String { dcCompound.fvPrimarySchool ?? "" }
    var compoundMiddleSchool: String { dcCompound.fvMiddleSchool ?? "" }
    
    var buildingLevelDecorate: DictType.LevelDecorate? {
        DictType.LevelDecorate(rawValue: dcBuilding.fvLevelDecorateFk ?? "" )
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
    
    var id: Int {
        networkInquiry["id"] as? Int ?? 0
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
    
    var address: String? { stringValue(of: "fvPropertyRightAddr") }
    var buildingArea: Double? {
        networkInquiry["fbBuildingArea"] as? Double
    }
    var contact: String? { stringValue(of: "fvContact") }
    var phone: String? { stringValue(of: "fvContactPhone") }
    var buildingYear: String? { stringValue(of: "fvBuildingYear") }
    var structure: DictType.BuildingStructure? {
        DictType.BuildingStructure(rawValue: stringValue(of: "fvBuildingStructure"))
    }
    var valuationDate: String? { stringValue(of: "fvValuationDate") }
    var housingUse: DictType.HousingUse? {
        DictType.HousingUse(rawValue: stringValue(of: "fvHousingUse"))
    }
    var landSe: DictType.LandSe? {
        DictType.LandSe(rawValue: stringValue(of: "fvLandSe"))
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
    let tradeType: String
    let date: String
    let caseAddress: String
    let decorate: String
    let floor: String
    let price: String
    let totalPrice: String
    let area: String
    let compoundAddress: String
    let totalFloor: String
}

struct RpsImage {
    let image: UIImage
    let filename: String
}

struct InquirySheet {
    var provinceCode: Int
    var cityCode: Int
    var areaCode: Int
    var provinceName: String
    var cityName: String
    var areaName: String
    var address: String
    var estateType: DictType.EstateType?
    var purpose: DictType.ValuationPurpose?
    var buildingArea: Double?
    var structure: DictType.BuildingStructure?
    var contact: String
    var phone: String
    var valuationDate: String
    
    var landArea: Double?
    var buildingYear: String
    var upperFloor: Double?
    var underFloor: Double?
    var beginFloor: Int?
    var endFloor: Int?
    var telephone: String
    var custodian: String
    
    var description: String
    var comment: String
    
    var images: [RpsImage]
    
    static var empty: Self {
        InquirySheet(
            provinceCode: 0,
            cityCode: 0,
            areaCode: 0,
            provinceName: "",
            cityName: "",
            areaName: "",
            address: "",
            estateType: nil,
            purpose: nil,
            buildingArea: nil,
            structure: nil,
            contact: "",
            phone: "",
            valuationDate: "",
            landArea: nil,
            buildingYear: "",
            upperFloor: nil,
            underFloor: nil,
            beginFloor: nil,
            endFloor: nil,
            telephone: "",
            custodian: "",
            description: "",
            comment: "",
            images: []
        )
    }
}

struct ReportSheet {
    var certificateAddress: String = ""
    var estateType: DictType.EstateType? = nil
    var clientName: String = ""
    var phone: String = ""
    var purpose: DictType.ValuationPurpose? = nil
    
    var provinceCode: Int = 0
    var cityCode: Int = 0
    var areaCode: Int = 0
    var provinceName: String = ""
    var cityName: String = ""
    var areaName: String = ""
    var address: String = ""
    var buildingArea: Double? = nil
    var buildingYear: Int? = nil
    var structure: DictType.BuildingStructure? = nil
    var landArea: Double? = nil
    var beginFloor: Int? = nil
    var endFloor: Int? = nil
    var valuationDate: String = ""
    var price: Int? = nil
    var totalPrice: Int? = nil
    var owner: String = ""
    var ownerNumber: String = ""
    var housingUse: DictType.HousingUse? = nil
    var facing: DictType.BuildDirection? = nil
    var landSe: DictType.LandSe? = nil
    var landUser: DictType.LandUser? = nil
    var landEndDate: String = ""
    var landNumber: String = ""
    var northTo: String = ""
    var southTo: String = ""
    var eastTo: String = ""
    var westTo: String = ""
    var traffic: String = ""
    var publicFacilities: String = ""
    var decoration: DictType.Decoration? = nil
    var levelDecorate: DictType.LevelDecorate? = nil
    var buildingNewDegree: Double? = nil
    var houseTransferee: String = ""
    var houseTransferAmount: Int? = nil
    var propertyCoOwnershipSituation: DictType.CoOwnershipSituation? = nil
    var propertyCoOwnership: String = ""
    var jointOwnershipCertificateNumber: String = ""
    var spatialLayout: DictType.SpatialLayout? = nil
    var houseUse: String = ""
    var compensation: String = ""
    var bkLander: String = ""
    var bkLandType: String = ""
    var organ: String = ""
    var organDept: String = ""
    var bankBranchCode: String = ""
    var comment: String = ""
    var images: [RpsImage] = []
}

enum RecordPage {
    case inquiry(SearchFilter), report(SearchFilter)
}

enum InquiryType: CaseIterable, HasLabel {
    case system, manual
    
    var label: String {
        switch self {
        case .system: return "系统询价"
        case .manual: return "人工询价"
        }
    }
    
    var dictKey: Int {
        switch self {
        case .system: return 1
        case .manual: return 2
        }
    }
}

enum InquiryState: CaseIterable, HasLabel {
    case _0, _1, _2, _3, _4, _5
    
    var label: String {
        switch self {
        case ._0: return "未提交"
        case ._1: return "待分配"
        case ._2: return "待接受"
        case ._3: return "询价中"
        case ._4: return "已报价"
        case ._5: return "已撤消"
        }
    }
    
    var dictKey: String {
        switch self {
        case ._0: return "0"
        case ._1: return "1"
        case ._2: return "2"
        case ._3: return "3"
        case ._4: return "4"
        case ._5: return "5"
        }
    }
}

enum ReportState: CaseIterable, HasLabel {
    case _0, _1, _2, _3, _4, _5, _6, _7
    
    var label: String {
        switch self {
        case ._0: return "待提交"
        case ._1: return "待分配"
        case ._2: return "待接受"
        case ._3: return "受理中"
        case ._4: return "审核中"
        case ._5: return "盖章中"
        case ._6: return "已完成"
        case ._7: return "已撤消"
        }
    }
    
    var dictKey: String {
        switch self {
        case ._0: return "0"
        case ._1: return "1"
        case ._2: return "2"
        case ._3: return "3"
        case ._4: return "4"
        case ._5: return "5"
        case ._6: return "6"
        case ._7: return "7"
        }
    }
}

enum DownloadState: CaseIterable {
    case _1, _2, _3, _4
    
    var label: String {
        switch self {
        case ._1: return "未申请下载"
        case ._2: return "下载申请审批中"
        case ._3: return "审批已通过，可下载"
        case ._4: return "暂不审批"
        }
    }
}

enum RecordType: CaseIterable, HasLabel {
    case personal, organize
    
    var label: String {
        switch self {
        case .organize: return "单位记录"
        case .personal: return "个人记录"
        }
    }
    
    var dictKty: String {
        switch self {
        case .personal:
            return "0"
        case .organize:
            return "1"
        }
    }
}

struct SearchFilter {
    var address: String = ""
    var recordType: RecordType?
    var estateType: DictType.EstateType?
    var inquiryType: InquiryType?
    var inquiryState: InquiryState?
    var startDate: String = ""
    var endDate: String = ""
    var startPrice: String = ""
    var endPrice: String = ""
    var clientName: String = ""
}

struct Record: Identifiable {
    let page: RecordPage
    let id: Int
    let imageURL: String
    let inquiryType: InquiryType?
    let district: String
    let estateType: DictType.EstateType
    let address: String
    let clientName: String
    let valuationDate: String
    let inquiryState: InquiryState?
    let reportState: ReportState?
    let downloadState: DownloadState?
    let totalPrice: String
    let price: String
    let area: String
    let roomId: String
    let buildingId: Int
    
    var displayTotalPrice: String {
        guard let d = Double(totalPrice) else { return "" }
        return "\(d / 10000)"
    }
}

struct RecordsResult {
    let total: Int
    let current: Int
    let records: [Record]
}

struct Template: Equatable {
    let id: Int
    let name: String
}

struct TemplateItem: Equatable {
    let name: String
}

struct ConsultReportSheet {
    var template: Template?
    var bankManager: String = ""
    var dept: String = ""
    var clientName: String = ""
    var landArea: Double?
    var houseNum: String = ""
    var landNum: String = ""
    var houseArea: Double?
    var quality: String = ""
    var landEndDate: String = ""
    var landUser: DictType.LandUser?
    var landSe: DictType.LandSe?
    var transferTo: String = ""
    var item1: String = ""
    var item2: String = ""
    var comment: String = ""
    var images: [RpsImage] = []
}
