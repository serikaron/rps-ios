//
//  datas.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation
import UIKit
import CoreLocation

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
    var area: String?
}

struct LandIndustrialFactory {
    var name: String?
    var area: String?
    var landUser: DictType.LandUser?
    var endDate: String?
    var landSe: DictType.LandSe?
    var roadCondition: DictType.TemporaryRoadConditions?
}

struct BuildIndustrialFactory {
    var name: String?
    var area: String?
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
    let compoundName: String
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
    var buildingArea: String?
    var structure: DictType.BuildingStructure?
    var contact: String
    var phone: String
    var valuationDate: String
    
    var landArea: String
    var buildingYear: String
    var upperFloor: Int?
    var underFloor: Int?
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
            landArea: "",
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
    var recordType: RecordType = .personal
    var estateType: DictType.EstateType?
    var inquiryType: InquiryType?
    var inquiryState: InquiryState?
    var reportState: ReportState?
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
    let provinceCode: Int
    let cityCode: Int
    let areaCode: Int
    let floor: String
    let contact: String
    let contactPhone: String
    let buildingYear: String
    let structure: DictType.BuildingStructure?
    let searchAddress: String
    let dataOrgId: Int
    
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
    var landArea: String = ""
    var houseNum: String = ""
    var landNum: String = ""
    var houseArea: String = ""
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
    let permissions: [String]
}

extension Account: Equatable {
    
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
    let coordinate: MapViewCoordinate?
    let picUrl: String
    let familyRoomName: String
    let areaCode: Int
    let estateType: String
    let buildingId: Int
    let floor: String
    let compoundId: Int
    
    static var empty: Self {
        MapCompound(name: "", alias: "", streetMark: "", north: "", south: "", east: "", west: "", location: "", coordinate: nil, picUrl: "", familyRoomName: "", areaCode: 0, estateType: "", buildingId: 0, floor: "", compoundId: 0)
    }
}

typealias Coordinate = CLLocationCoordinate2D
extension Coordinate: Decodable {
    private enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
    }
    public init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try value.decode(Double.self, forKey: .latitude)
        let longitude = try value.decode(Double.self, forKey: .longitude)
        
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}

enum MapViewCoordinate {
    case point([Coordinate])
    case line([Coordinate])
    case plane([Coordinate])
}
