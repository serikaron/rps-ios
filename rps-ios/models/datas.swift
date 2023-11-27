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
    
    static func from(pickerImage: ImagePicker.ImageInfo) -> Self {
        var filename = ""
        if let url = URL(string: pickerImage.imageURL) {
            filename = url.lastPathComponent
        } else {
            filename = UUID().uuidString
        }
        return RpsImage(image: pickerImage.image, filename: filename)
    }
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

struct SearchFilter: Equatable {
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
    let areaCode: Int
    let floor: String
    
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

struct Message {
    let id: Int
    let content: String
    var read: Bool
    let date: String
    let sender: String
}

enum Gender {
    case male, female
    
    init?(rawValue: String?) {
        switch rawValue {
        case "1": self = .male
        case "2": self = .female
        default: return nil
        }
    }
    
    var dictKey: String {
        switch self {
        case .male: return "1"
        case .female: return "2"
        }
    }
    
    var label: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        }
    }
}

struct Account {
    let id: Int
    let orgId: Int
    let unitId: Int
    let nickname: String
    let phone: String
    let placeOrganization: String
    let placeUnit: String
    let clientName: String
    let position: String
    let status: DictType.CommonStatus
    let date: String
    var gender: Gender
    var birthday: String
    let email: String
    let workPhone: String
}

struct MapCompound {
    let name: String
    let alias: String
    let streetMark: String
    let north: String
    let south: String
    let east: String
    let west: String
    let location: String
    let coordinate: Coordinate?
    let picUrl: String
    let familyRoomName: String
    let areaCode: Int
    let estateType: String
    let buildingId: Int
    let floor: String
    
    static var empty: Self {
        MapCompound(name: "", alias: "", streetMark: "", north: "", south: "", east: "", west: "", location: "", coordinate: nil, picUrl: "", familyRoomName: "", areaCode: 0, estateType: "", buildingId: 0, floor: "")
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}
