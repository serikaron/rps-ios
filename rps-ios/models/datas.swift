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

enum EstateType {
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
}

@MainActor
struct RoomDetail {
    let networkRoomDetail: Linkman.NetworkRoomDetail
    let roomCount: Int
    
    static var empty: RoomDetail {
        RoomDetail(networkRoomDetail: .empty, roomCount: 0)
    }
    
    private let nilText: String = "无"
    
    var estateType: EstateType? {
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
    var landUser: String {
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
            else { return nilText }
            return DictType.landUser.label(of: landUser) ?? nilText
        case .landingRoom:
            guard let landUser = hasRoom ? networkRoomDetail.fvLandUser : dcBuilding.fvLandUser
            else { return nilText }
            return DictType.landUser.label(of: landUser) ?? nilText
        case .shopStreet:
            guard let landUser = dcCompound.fvLandUser else { return nilText }
            return DictType.landUser.label(of: landUser) ?? nilText
        case .industrialFactory:
            fallthrough
        case nil:
            return nilText
        }
    }
    var completionDate: String {
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
    var position: String {
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
            DictType.noRoomPositon.label(of: position) ?? nilText
        case .landingRoom:
            guard let position = networkRoomDetail.fvLandingroomPosition else { return nilText }
            return hasRoom ?
            DictType.landingroomPosition.label(of: position) ?? nilText :
            DictType.noRoomPositon.label(of: position) ?? nilText
        case .shopStreet:
            guard let position = networkRoomDetail.fvShopPosition else { return nilText }
            return hasRoom ?
            DictType.shopPosition.label(of: position) ?? nilText :
            DictType.noRoomPositon.label(of: position) ?? nilText
        case .industrialFactory:
            fallthrough
        case nil: return nilText
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
    var height: String {
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
    var floor: String? {
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
}
