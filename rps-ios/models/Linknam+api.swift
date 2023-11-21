//
//  Linknam+.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation
import UIKit

extension Linkman {
    struct LoginResponse: Codable {
        let access_token: String
    }
    
    func login(phone: String, password: String) async throws -> LoginResponse {
        return try await Request()
            .with(\.path, setTo: "/auth/rps/clientLogin")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["username": phone, "password": password, "deviceType": "APP"])
            .with(\.standaloneResponse, setTo: standaloneResponse(LoginResponse(access_token: "mockToken")))
            .make()
            .response() as LoginResponse
    }
    
    struct NetworkUser: Codable {
        let id: Int
        let fiOrgId: Int
        let fiUnitId: Int
        let fvClientNickName: String
        let fiCellphone: Int
        let fvPlaceUnit: String
        let fvPlaceOrganization: String
    }
    
    struct GetInfoResponse: Codable {
        let user: NetworkUser
    }
    
    func getInfo() async throws -> GetInfoResponse {
        return try await Request()
            .with(\.path, setTo: "/account/rps/account/clientUser/getInfo")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse(GetInfoResponse.mock))
            .make()
            .response() as GetInfoResponse
    }
    
    func register(account: String, name: String, gender: Gender, birthday: String,
                  company: String, department: String, position: String,
                  phone: String, mobile: String, email: String, contact: String,
                  address: String
    ) async throws {
        try await Request()
            .with(\.path, setTo: "/account/rps/account/clientUser/applyLoginClientUser")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "fvClientName": account,
                "fvClientNickName": name,
                "fvClientGender": gender.text,
                "fdDateBirth": birthday,
                "fvPlaceUnit": company,
                "fvPlaceOrganization": department,
                "fvPosition": position,
                "fiWorkPhone": phone,
                "fiCellphone": mobile,
                "fvEmail": email,
                "fvQqMsn": contact,
                "fvPlaceArea": address
            ])
            .make()
    }
    
    struct NoticeRecord: Codable {
        let noticeTitle: String
    }
    
    struct NoticeResponse: Codable {
        let records: [NoticeRecord]
    }
    
    func getNotices(pageNum: Int, pageSize: Int, orgId: Int) async throws -> NoticeResponse {
        return try await Request()
            .with(\.path, setTo: "/system/rps/rpsNotice/page")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "pageNum": "\(pageNum)", "pageSize": "\(pageSize)", "orgId": "\(orgId)",
                "type": "3", "fvPushstatus": "已发布", "fiTypeOfNotice": "0,2,3"
            ])
            .with(\.standaloneResponse, setTo: standaloneResponse(NoticeResponse(records: [NoticeRecord.mock])))
            .make()
            .response() as NoticeResponse
    }
    
    struct NetworkSearchResult: Codable {
        let id: String
        let fvFamilyRoomName: String?
        let fvEstateType: String?
        let fiAreaCode: Int?
        let fiCompoundId: Int?
        let fvCompoundName: String?
        let fvNameAlias: String?
        let fvStreetMark: String?
        let picUrls: String?
        let fvCompletionDate: String?
        let fiBuildingId: Int?
        let fvInFloor: String?
    }
    
    typealias FuzzySearchResopnse = [NetworkSearchResult]
    
    func fuzzySearch(keyword: String) async throws -> FuzzySearchResopnse {
        return try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/selectRoomAddr")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvFamilyRoomName": keyword
            ])
            .with(\.standaloneResponse, setTo: standaloneResponse([NetworkSearchResult.mock]))
            .make()
            .response() as FuzzySearchResopnse
    }
    
    struct ExactSearchResponse: Codable {
        let records: [NetworkSearchResult]
        let total: Int
        let size: Int
    }
    
    func exactSearch(keyword: String, pageSize: Int, pageNum: Int) async throws -> ExactSearchResponse {
        return try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/getCompoundByComName")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvCompoundName": keyword,
                "pageSize": "\(pageSize)",
                "pageNum": "\(pageNum)"
            ])
//            .with(\.standaloneResponse, setTo: standaloneResponse(ExactSearchResponse(records: [NetworkSearchResult.mock])))
            .with(\.standaloneResponse, setTo: standaloneResponse(ExactSearchResponse(
                records: (pageSize*(pageNum-1)..<pageSize*(pageNum)).map { NetworkSearchResult.mockResult(num: $0)},
                total: 10,
                size: pageSize
            )))
            .make()
            .response() as ExactSearchResponse
    }
    
    struct NetworkDictItem: Codable {
        let dictTypeName: String?
        let dictLabel: String?
        let dictValue: String?
        let dictSort: Int?
    }
    
    struct NetworkDictType: Codable {
        let dictType: String?
        let sysDictDataList: [NetworkDictItem]
    }
    
    typealias DictResponse = [NetworkDictType]
    
    func getDict() async throws -> DictResponse {
        return try await Request()
            .with(\.path, setTo: "/system/dict/type/selectList")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse(DictResponse.mock))
            .make()
            .response() as DictResponse
    }
    
    struct BuildingsResponse: Codable {
        let records: Buildings
        let total: Int
        let size: Int
    }
    
    func getBuildings(compoundId: Int, estateType: String, pageSize: Int, pageNum: Int) async throws -> BuildingsResponse {
        return try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/getBuildingByComId")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "fiCompoundId": "\(compoundId)",
                "fvEstateType": estateType,
                "pageSize": "\(pageSize)",
                "pageNum": "\(pageNum)"
            ])
            .with(\.standaloneResponse, setTo: standaloneResponse(BuildingsResponse(
                records: [Building.mock], total: 1, size: 1)))
            .make()
            .response() as BuildingsResponse
    }
    
    typealias RoomCountResponse = Int
    
    func getRoomCount(estateType: String, buildingId: Int) async throws -> RoomCountResponse {
        try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/selectRoomCount")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "estateType": estateType,
                "fiBuildingId": "\(buildingId)"
            ])
            .make()
            .response() as RoomCountResponse
    }
    
    struct UnitInfo: Codable {
        let keys: String?
        let type: String?
        let order: String?
        let unitName: String?
    }

    struct BuildingFloors: Codable {
        let unitInfoResponseList: [UnitInfo]
        let floorData: [FloorData]
    }
    
    struct FloorData: Codable {
        let units: [String: FloorDataItems]
        let louceng: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicKey.self)
            
            var louceng: String?
            var units = [String: FloorDataItems]()
            try container.allKeys.forEach { key in
                if key.stringValue == "louceng" {
                    louceng = try container.decode(String.self, forKey: key)
                    return
                }
                
                do {
                    let items = try container.decode(FloorDataItems.self, forKey: key)
                    units[key.stringValue] = items
                } catch {}
            }
            
            self.louceng = louceng
            self.units = units
        }
    }
    
    struct FloorDataItem: Codable {
        let fiFloorNum: Int?
        let fvRoomNum: String?
        let fvRoomName: String?
        let fvFamilyRoomName: String?
        let fiAreaCode: Int?
        let fvEstateType: String?
        let fiBuildingId: Int?
        let fvInFloor: String?
    }
    
    struct FloorDataItems: Codable {
        let items: [FloorDataItem]
    }
    
    typealias BuildingFloorsResponse = BuildingFloors
    
    func getBuildingFloors(buildingId: Int, estateType: String, areaCode: Int) async throws -> BuildingFloors {
        try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/getBaseData")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvEstateType": estateType,
                "fiBuildingId": "\(buildingId)",
                "fiAreaCode": "\(areaCode)",
                "buildingEnterFlag": "0",
                "isPutRoomBaseData": "false",
                "collectRoomTableFlag": "0"
            ])
            .make()
            .response() as BuildingFloors
    }
    
    struct DCBuilding: Codable {
        var fvHouseProperty: String?
        var fvBuildingStructure: String?
        var fiLandUpperCount: Int?
        var fvHousingUse: String?
        var fvLandingroomLandSe: String?
        var fvLandUser: String?
        var fdCompletionDate: String?
        var fvEstateType: String?
        var fvBuildDirection: String?
        var fvSpecialCircumstances: String?
        var fvLevelDecorateFk: String?
    }
    
    struct DCCompound: Codable {
        var fvLandUser: String?
        var fvCompletionDate: String?
        var fvLandLevel: String?
        var fvSpecialCircumstances: String?
        var fvHouseProperty: String?
        var fvDeveloper: String?
        var fvConstruction: String?
        var fvSaleCompany: String?
        var fvSaleAddress: String?
        var fvSalePhoneno: String?
        var fvSaleTime: String?
        var fvCityName: String?
        var fvAreaName: String?
        var fvSubdistrictName: String?
        var fvCompoundName: String?
        var fbLandArea: Double?
        var fvToEast: String?
        var fvToWest: String?
        var fvToSouth: String?
        var fvToNorth: String?
        var fvBusLineName: String?
        var fvFastBus: String?
        var fvSubwayName: String?
        var fvVegeMarket: String?
        var fvBusinessSet: String?
        var fvHospital: String?
        var fvFinaceOrg: String?
        var fvStadium: String?
        var fvRelaxSquare: String?
        var fvKindergarten: String?
        var fvPrimarySchool: String?
        var fvMiddleSchool: String?
    }
    
    struct NetworkRoomDetail: Codable {
        var fvFamilyRoomName: String?
        var fvProvinceName: String?
        var fvCityName: String?
        var fvAreaName: String?
        var fvSubdistrictName: String?
        var fvEstateType: String?
        var estateTypeLabel: String?
        var fvLandUser: String?
        var fdCompletionDate: String?
        var fvBuildingStructure: String?
        var fvOrientation: String?
        var fvFloorHeight: String?
        var fvInFloor: String?
        var fvHouseProperty: String?
        var fvHousingUse: String?
        var fvPosition: String?
        var fvLandingroomPosition: String?
        var fvShopPosition: String?
        var wuYeFenLei: String?
        var fiLandUpperCount: Int?
        var fvLandingroomLandSe: String?
        var fvCompoundName: String?
        var fiCompoundId: Int?
        var fvSpecialCircumstances: String?
        var fvTypeOfHouse: String?
        var fvDaylighting: String?
        var fvNoise: String?
        var fvdecoration: String?
        var fv_landscape: String?
        var fv_garden: String?
        var fv_terrace: String?
        var fv_attic: String?
        var fv_basement: String?
        
        var buildingImageList: [RoomDetailImage]
        var compoundImageList: [RoomDetailImage]

        var dcBuilding: DCBuilding
        var dcCompound: DCCompound
    }
    
    struct RoomDetailImage: Codable {
        let fvUrl: String?
    }
    
    typealias RoomDetailResponse = NetworkRoomDetail
    
    func getRoomDetail(estateType: String, areaCode: Int, familyRoomName: String, orgId: Int) async throws -> RoomDetailResponse {
        try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/getRoomDetail")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvEstateType": estateType,
                "fiAreaCode": "\(areaCode)",
                "fvFamilyRoomName": familyRoomName,
                "orgId": "\(orgId)"
            ])
            .make()
            .response() as RoomDetailResponse
    }
    
//    struct NetworkInquiry {
//        var dict: [String: Any]
//        
//        init(from data: Data) throws {
//            guard let d = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//            else { throw "decode NetworkInquiry FAILED" }
//            self.dict = d
//        }
//        
//        init() {
//            self.dict = [:]
//        }
//    }
    
    typealias NetworkInquiry = [String: Any]
    
    func createInquiry(buildingId: Int, estateType: String, areaCode: Int, searchAddr: String, orgId: Int) async throws -> NetworkInquiry {
        let req = try await Request()
            .with(\.path, setTo: "/inquiry/rps/inquiry/addSystem")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "fiBuildingId": "\(buildingId)",
                "fvEstateType": estateType,
                "fiAreaCode": areaCode,
                "fvSearchAddr": searchAddr,
                "fiOrgId": orgId
            ])
            .make()
        
        guard let data = req._response else {
            throw "response not exits"
        }
        
        guard let dataDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let out = dataDict["data"] as? NetworkInquiry
        else {
            throw "data not in response"
        }
        
        return out
    }
    
    func inquire(inquiry: NetworkInquiry) async throws -> NetworkInquiry {
        let req = try await Request()
            .with(\.path, setTo: "/inquiry/rps/inquiry/systemInquiry")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: inquiry)
            .make()
        
        guard let data = req._response else {
            throw "response not exits"
        }
        
        guard let dataDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let out = dataDict["data"] as? NetworkInquiry
        else {
            throw "data not in response"
        }
        
        return out
    }
    
    func inquireDetail(inquiry: NetworkInquiry) async throws -> NetworkInquiry {
        let req = try await Request()
            .with(\.path, setTo: "/inquiry/rps/inquiry/systemDetailInquiry")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: inquiry)
            .make()
        
        guard let data = req._response else {
            throw "response not exits"
        }
        
        guard let dataDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let out = dataDict["data"] as? NetworkInquiry
        else {
            throw "data not in response"
        }
        
        return out
    }
    
    struct RoomCase: Codable {
        let fiTradeType: Int?
        let fvCaseTime: String?
        let fvCaseAddress: String?
        let fvDecoration: String?
        let fbPrice: Double?
        let fbTotalPrice: Double?
        let fbArea: Double?
        let fvInFloor: String?
        let fvCompoundMatchAddress: String?
        let fiTotalFloor: Int?
    }
    
    typealias RoomCasesResponse = [RoomCase]
    
    func getRoomCases(compoundId: Int, estateType: String, price: Double) async throws -> RoomCasesResponse {
        try await Request()
            .with(\.path, setTo: "/cases/rps/CcCase/listRoomMatchCases")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "fiCompoundId": compoundId,
                "fvEstateType": estateType,
                "fbPrice": price
            ])
            .make()
            .response() as RoomCasesResponse
    }
    
    struct NetworkBanner: Codable {
        let fvOssUrl: String?
    }
    
    typealias BannersResponse = [NetworkBanner]
    
    func getBanners() async throws -> BannersResponse {
        try await Request()
            .with(\.path, setTo: "/system/rps/banner/list")
            .with(\.method, setTo: .GET)
            .make()
            .response() as BannersResponse
    }
    
    struct AuthArea: Codable {
        let fiAreaCode: Int?
    }
    
    typealias AuthAreaListResponse = [AuthArea]
    
    func getAuthAreaList(unitId: Int) async throws -> AuthAreaListResponse {
        try await Request()
            .with(\.path, setTo: "/account/rps/account/clientUser/getRpsAuthAreaList")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: ["fiUnitId": "\(unitId)"])
            .make()
            .response() as AuthAreaListResponse
    }
    
    struct CurveData: Codable {
        let verticalShaft: [Double]
        let horizontalAxis: [String]
        
        init(from dict: [String: Any]) {
            if let vsList = dict["verticalShaft"] as? [Any] {
                self.verticalShaft = vsList.map { vs in
                    if let i = vs as? Int {
                        return Double(i)
                    }
                    if let d = vs as? Double {
                        return d
                    }
                    if let s = vs as? String {
                        return Double(s) ?? 0
                    }
                    return 0
                }
            } else {
                self.verticalShaft = []
            }
            
            if let haList = dict["horizontalAxis"] as? [String] {
                self.horizontalAxis = haList
            } else {
                self.horizontalAxis = []
            }
        }
    }
    
    struct DistrictCurve: Codable {
        let code: String
        let value: CurveData
        
        init(from dict: [String: Any]) {
            self.code = dict["code"] as? String ?? ""
            if let valueDict = dict["value"] as? [String: Any] {
                self.value = CurveData(from: valueDict)
            } else {
                self.value = CurveData(from: [:])
            }
        }
    }
    
    typealias CurveResponse = [DistrictCurve]
    
    func getCurve(startTime: String, endTime: String, estateType: String, districtId: [Int]) async throws -> CurveResponse {
        let req = try await Request()
            .with(\.path, setTo: "/pricing/rps/pcBaseCompoundPrice/districtAndCountyCurve")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "startTime": startTime,
                "endTime": endTime,
                "fvEstateType": estateType,
                "fiDistrictId": districtId
            ])
            .make()
        
        guard let response = req._response else {
            throw "response not exits"
        }
        
        guard let responseDict = try JSONSerialization.jsonObject(with: response) as? [String: Any],
              let data = responseDict["data"] as? [[String: Any]]
        else {
            throw "mismatch data type"
        }
        
        return data.compactMap { DistrictCurve(from: $0) }
    }
    
    typealias CombinedCurveResponse = CurveData
    
    func getCombinedCurve(startTime: String, endTime: String, estateType: String, districtId: [Int]) async throws -> CombinedCurveResponse {
        let req = try await Request()
            .with(\.path, setTo: "/pricing/rps/pcBaseCompoundPrice/districtAndCombinedCountyCurve")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "startTime": startTime,
                "endTime": endTime,
                "fvEstateType": estateType,
                "fiDistrictId": districtId
            ])
            .make()
        
        guard let response = req._response else {
            throw "response not exits"
        }
        
        guard let responseDict = try JSONSerialization.jsonObject(with: response) as? [String: Any],
              let data = responseDict["data"] as? [String: Any]
        else {
            throw "mismatch data type"
        }

        return CombinedCurveResponse(from: data)
    }
    
    struct CompoundCurveData: Codable {
        let evaluateTime: String?
        let price: Double?
    }
    
    typealias CompoundCurveResponse = [CompoundCurveData]
    
    func getCompoundCurve(compoundId: Int, startTime: String, endTime: String, estateType: String) async throws -> CompoundCurveResponse {
        try await Request()
            .with(\.path, setTo: "/pricing/pcBaseCompoundPrice/getCompoundCommuntyCharts")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvCompoundId": "\(compoundId)",
                "fdEvaluateTimeStart": startTime,
                "fdEvaluateTimeEnd": endTime,
                "fvEstateType": estateType
            ])
            .make()
            .response() as CompoundCurveResponse
    }
    
    func getBaseDistrictCurve(compoundId: Int, startTime: String, endTime: String, estateType: String) async throws -> CompoundCurveResponse {
        try await Request()
            .with(\.path, setTo: "/pricing/rps/pcBaseCompoundPrice/getPcBasePriceDistrictLineChart")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "fvCompoundId": "\(compoundId)",
                "fdEvaluateTimeStart": startTime,
                "fdEvaluateTimeEnd": endTime,
                "fvEstateType": estateType
            ])
            .make()
            .response() as CompoundCurveResponse
    }
    
    struct UploadResponse: Codable {
        let ossId: String?
        let originalName: String?
        let fileName: String?
        let createTime: String?
        let url: String?
        let fileSuffix: String?
    }
    
    func upload(image: UIImage, filename: String) async throws -> UploadResponse {
        try await Request()
            .with(\.path, setTo: "/resource/rps/oss/upload")
            .with(\.method, setTo: .POST)
            .uploadInfo(filename: filename, data: image.pngData()!)
            .make()
            .response() as UploadResponse
    }
    
    func addInquiry(inquiryDict: [String: Any]) async throws {
        try await Request()
            .with(\.path, setTo: "/inquiry/rps/mkInquiry/add")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: inquiryDict)
            .make()
    }
    
    func addReport(reportDict: [String: Any]) async throws {
        try await Request()
            .with(\.path, setTo: "/inquiry/rps/complexReport/add")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: reportDict)
            .make()
    }
    
    struct NetworkArea: Codable {
        let id: String
        let label: String
        let children: [NetworkArea]
    }
    
    typealias AreaTreeResponse = NetworkArea
    
    func getAreaTree() async throws -> AreaTreeResponse {
        try await Request()
            .with(\.path, setTo: "/system/rps/rdsArea/getAllAreaTree")
            .with(\.method, setTo: .GET)
            .make()
            .response() as AreaTreeResponse
    }
}


struct DynamicKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = ""
    }
}

extension Linkman.DCBuilding {
    static var empty: Linkman.DCBuilding {
        Linkman.DCBuilding(
            fvHouseProperty: "",
            fvBuildingStructure: "",
            fiLandUpperCount: 0,
            fvHousingUse: "",
            fvLandingroomLandSe: "",
            fvLandUser: "",
            fdCompletionDate: "",
            fvEstateType: "",
            fvBuildDirection: "")
    }
}

extension Linkman.DCCompound {
    static var empty: Linkman.DCCompound {
        Linkman.DCCompound(fvLandUser: "", fvCompletionDate: "", fvLandLevel: "")
    }
}

extension Linkman.NetworkRoomDetail {
    static var empty: Linkman.NetworkRoomDetail {
        Linkman.NetworkRoomDetail(
            fvFamilyRoomName: "",
            fvProvinceName: "",
            fvCityName: "",
            fvAreaName: "",
            fvSubdistrictName: "",
            fvEstateType: "",
            estateTypeLabel: "",
            fvLandUser: "",
            fdCompletionDate: "",
            fvBuildingStructure: "",
            fvOrientation: "",
            fvFloorHeight: "",
            fvInFloor: "",
            fvHouseProperty: "",
            fvHousingUse: "",
            fvPosition: "",
            fvLandingroomPosition: "",
            fvShopPosition: "",
            wuYeFenLei: "",
            fiLandUpperCount: 0,
            fvLandingroomLandSe: "",
            buildingImageList: [],
            compoundImageList: [],
            dcBuilding: .empty, dcCompound: .empty)
    }
}
