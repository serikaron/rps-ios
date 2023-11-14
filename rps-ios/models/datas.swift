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
}
typealias Rooms = [Room]

struct RoomDetail: Codable {
    let fvFamilyRoomName: String?
    let fvProvinceName: String?
    let fvCityName: String?
    let fvAreaName: String?
    let fvSubdistrictName: String?
    let fvEstateType: String?
    let estateTypeLabel: String?
    let fvLandUser: String?
    let fvCompletionDate: String?
    let fvBuildingStructure: String?
    let fvOrientation: String?
    let fvFloorHeight: String?
    let fvInFloor: String?
    let fvHouseProperty: String?
    let fvHousingUse: String?
    
    var roomName: String { fvFamilyRoomName ?? "" }
    var address: String {
        return "\(fvProvinceName ?? "")" +
        "\(fvCityName ?? "")" +
        "\(fvAreaName ?? "")" +
        "\(fvSubdistrictName ?? "")" +
        "\(fvFamilyRoomName ?? "")"
    }
    var estateType: String { estateTypeLabel ?? "无" }
    var landUser: String { fvLandUser ?? "无" }
    var completionDate: String { fvCompletionDate ?? "无" }
    var position: String { "无" }
    var structure: String { fvBuildingStructure ?? "无" }
    var facing: String { fvOrientation ?? "无" }
    var height: String { fvFloorHeight ?? "无" }
    var floor: String { fvInFloor ?? "无" }
    var property: String { fvHouseProperty ?? "无" }
    var usage: String { fvHousingUse ?? "无" }
}
