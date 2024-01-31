//
//  data+Inquiry.swift
//  rps-ios
//
//  Created by serika on 2023/11/28.
//

import Foundation


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
    var areaString: String? {
        get { stringValue(of: "fbBuildingArea") }
        set(value) { setString(value, of: "fbBuildingArea") }
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
                    area: areaString
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
                    area: land["landArea"] as? String,
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
                    area: building["fbBuildingArea"] as? String,
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
    var provinceCode: Int? {
        networkInquiry["fiProvinceCode"] as? Int
    }
    var cityCode: Int? {
        networkInquiry["fiCityCode"] as? Int
    }
    var areaCode: Int? {
        networkInquiry["fiAreaCode"] as? Int
    }
    var otherPriceInfos: [OtherPriceInfo] {
        do {
            guard let s = stringValue(of: "fvOtherPriceInfo"),
                  let data = s.data(using: .utf8)
            else { return [] }
            
            return try data.decoded() as [OtherPriceInfo]
        } catch {
            return []
        }
    }
    
    var coverImg: String? {
        get { return stringValue(of: "fvCoverImg") }
        set(value) { setString(value, of: "fvCoverImg")}
    }
    
    var purpose: DictType.ValuationPurpose? {
        DictType.ValuationPurpose(rawValue: stringValue(of: "fvValuationPurpose"))
    }
    
    var upperFloor: Int? {
        networkInquiry["fiLandUpperCount"] as? Int
    }
    
    var lowerFloor: Int? {
        networkInquiry["fiLandLowerCount"] as? Int
    }
    
    var telephone: String? {
        networkInquiry["fvFixedTelephone"] as? String
    }
    
    var custodian: String? {
        networkInquiry["fvBusinessCustodian"] as? String
    }
}

struct OtherPriceInfo: Decodable {
    let name: String?
    let price: String?
    let totalPrice: String?
}
