//
//  Linknam+.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

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
        let fiCompoundId: Int?
        let fvCompoundName: String?
        let fvNameAlias: String?
        let fvStreetMark: String?
        let picUrls: String?
        let fvCompletionDate: String?
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
    }

    struct BuildingFloors: Codable {
        let unitInfoResponseList: [UnitInfo]
        let floorData: [FloorData]
    }
    
    struct FloorData: Codable {
        let units: [String: FloorDataItems]
        let louceng: String?
        
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
    }
    
    struct FloorDataItems: Codable {
        let items: [FloorDataItem]
    }
    
    typealias BuildingFloorsResponse = BuildingFloors
    
    func getBuildingFloors(buildingId: Int, estateType: String, areaCode: Int) async throws -> BuildingFloors {
        try await Request()
            .with(\.path, setTo: "/data/\(estateType)/room/getBaseData")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvEstateType": estateType,
                "fiBuildingId": "\(buildingId)",
                "fiAreaCode": "\(areaCode)"
            ])
            .make()
            .response() as BuildingFloors
    }
    
    typealias RoomDetailResponse = RoomDetail
    
    func getRoomDetail(estateType: String, areaCode: Int, familyRoomName: String) async throws -> RoomDetailResponse {
        try await Request()
            .with(\.path, setTo: "/data/rps/dcdata/getRoomDetail")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "fvEstateType": estateType,
                "fiAreaCode": "\(areaCode)",
                "fvFamilyRoomName": familyRoomName
            ])
            .make()
            .response() as RoomDetailResponse
    }
}

