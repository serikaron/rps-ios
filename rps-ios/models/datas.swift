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
}
typealias Rooms = [Room]

enum EstateType {
    case commApartment
    
    init?(_ value: String?) {
        switch value {
        case "commApartment": self = .commApartment
        default: return nil
        }
    }
}

@MainActor
struct RoomDetail {
    let networkRoomDetail: Linkman.NetworkRoomDetail
    let roomCount: Int
    
    private let nilText: String = "无"
    
    private var _type: EstateType? {
        EstateType(networkRoomDetail.fvEstateType)
    }
    
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
    var estateType: String {
        guard let t = networkRoomDetail.fvEstateType else { return nilText }
        let out = DictType.estate.label(of: t) ?? nilText
        switch _type {
        case .commApartment:
            return out
        case nil: return nilText
        }
    }
    var landUser: String {
        switch _type {
        case .commApartment:
            guard let landUser = hasRoom ? networkRoomDetail.fvLandUser : dcCompound.fvLandUser
            else { return nilText }
            return DictType.landUser.label(of: landUser) ?? nilText
        case nil: return nilText
        }
    }
    var completionDate: String {
        switch _type {
        case .commApartment:
            // 未确定
            return dcCompound.fvCompletionDate ?? nilText
        case nil: return nilText
        }
    }
    var position: String {
        // 未确定
        switch _type {
        case .commApartment:
            guard let position = networkRoomDetail.fvPosition else { return nilText }
            return DictType.position.label(of: position) ?? nilText
        case nil: return nilText
        }
    }
    var structure: String {
        switch _type {
        case .commApartment:
            guard let bs = dcBuilding.fvBuildingStructure else { return nilText }
            return DictType.buildingStructure.label(of: bs) ?? nilText
        case nil: return nilText
        }
    }
    var facing: String {
        // 楼幢没有orientation
        switch _type {
        case .commApartment:
            guard let o = networkRoomDetail.fvOrientation else { return nilText }
            return DictType.orientation.label(of: o) ?? nilText
        case nil: return nilText
        }
    }
    var height: String {
        switch _type {
        case .commApartment:
            return "\(dcBuilding.fiLandUpperCount ?? 0)"
        case nil: return "0"
        }
    }
    var floor: String {
        // 自动解释？
        switch _type {
        case .commApartment:
            return hasRoom ?
            networkRoomDetail.fvInFloor ?? nilText :
            nilText
        case nil: return nilText
        }
    }
    var property: String {
        switch _type {
        case .commApartment:
            guard let hp = hasRoom ? networkRoomDetail.fvHouseProperty :
                    dcBuilding.fvHouseProperty
            else { return nilText }
            return DictType.houseProperty.label(of: hp) ?? nilText
        case nil:
            return nilText
        }
    }
    var usage: String {
        switch _type {
        case .commApartment:
            guard let hu = hasRoom ? networkRoomDetail.fvHousingUse :
                    dcBuilding.fvHousingUse
            else { return nilText }
            return DictType.housingUse.label(of: hu) ?? nilText
        case nil:
            return nilText
        }
    }
}
