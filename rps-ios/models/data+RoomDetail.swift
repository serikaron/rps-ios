//
//  data+RoomDetail.swift
//  rps-ios
//
//  Created by serika on 2023/11/24.
//

import Foundation

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
        get {
            DictType.EstateType(networkRoomDetail.fvEstateType)
        }
        set(value) { networkRoomDetail.fvEstateType = value?.dictKey }
    }
    var estateTypeString: String? { networkRoomDetail.fvEstateType }
    var estateTypeLabel: String { estateType?.label ?? "" }
    
    private var dcBuilding: Linkman.DCBuilding { networkRoomDetail.dcBuilding }
    private var dcCompound: Linkman.DCCompound { networkRoomDetail.dcCompound }
    
    var hasRoom: Bool { roomCount > 0 }
    
    var roomName: String {
        get {networkRoomDetail.fvFamilyRoomName ?? ""}
        set(value) { networkRoomDetail.fvFamilyRoomName = value }
    }
    var address: String {
        return "\(dcBuilding.fvProvinceName ?? "")" +
        "\(dcBuilding.fvCityName ?? "")" +
        "\(dcBuilding.fvAreaName ?? "")" +
        "\(dcBuilding.fvSubdistrictName ?? "")" +
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
            guard let t = dcBuilding.fvPropertyClassifyThirdVilla else { return nilText }
            return DictType.valueOf(type: .fv_property_classify_third_villa, key: t) ?? nilText
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
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
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
        case .villa:
            guard let position = networkRoomDetail.fvPosition else { return nilText }
            return DictType.valueOf(type: .fv_property_classify_third_villa, key: position) ?? position
        case .industrialFactory:
            fallthrough
        case nil: return nilText
        }
    }
    var positionKey: String? {
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
                return networkRoomDetail.fvPosition
            case .landingRoom:
                return networkRoomDetail.fvLandingroomPosition
            case .shopStreet:
                return networkRoomDetail.fvShopPosition
            case .industrialFactory:
                fallthrough
            case nil: return nil
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
    var facingKey: String? {
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
                networkRoomDetail.fvOrientation :
                dcBuilding.fvBuildDirection
                
            case .shopStreet:
                return dcBuilding.fvBuildDirection
                
            case .industrialFactory:
                fallthrough
            case nil: return nil
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
        guard let hp = propertyKey else { return nilText }
        return DictType.houseProperty.label(of: hp) ?? nilText
    }
    var propertyKey: String? {
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
                return hasRoom ? networkRoomDetail.fvHouseProperty :
                dcBuilding.fvHouseProperty
                
            case .landingRoom:
                fallthrough
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
            case .shopStreet:
                fallthrough
            case .industrialSmallGarden:
                if hasRoom {
                    networkRoomDetail.fvHouseProperty = value
                } else {
                    networkRoomDetail.dcBuilding.fvHouseProperty = value
                }
                
            case .landingRoom:
                fallthrough
            case .industrialFactory:
                fallthrough
            case nil:
                break
            }
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
    var wuYeFenLeiText: String {
        switch estateType {
        case .commApartment:
            return DictType.fv_property_classify_third.label(of: wuYeFenLei) ?? ""
        case .singleApartment:
            return DictType.fv_property_classify_third_other.label(of: wuYeFenLei) ?? ""
        case .villa:
            return DictType.fv_property_classify_third_villa.label(of: wuYeFenLei) ?? ""
        case .office:
            return DictType.fv_property_classify_third_other.label(of: wuYeFenLei) ?? ""
        case .landingRoom:
            return DictType.fv_property_classify_third_landingroom.label(of: wuYeFenLei) ?? ""
        case .shopStreet:
            return DictType.fv_shops_property_classify_third_shopstreet.label(of: wuYeFenLei) ?? ""
        case .industrialSmallGarden:
            return DictType.fv_property_classify_third_other.label(of: wuYeFenLei) ?? ""
        case .industrialFactory:
            return ""
        case nil:
            return ""
        }
    }
    var compoundId: Int {
        get { networkRoomDetail.fiCompoundId ?? 0 }
        set(value) { networkRoomDetail.fiCompoundId = value }
    }
    var areaName: String {
        get { networkRoomDetail.fvAreaName ?? "" }
        set(value) { networkRoomDetail.fvAreaName = value }
    }
    var provinceCode: Int {
        networkRoomDetail.fiProvinceCode ?? 0
    }
    var cityCode: Int {
        networkRoomDetail.fiCityCode ?? 0
    }
    var areaCode: Int {
        networkRoomDetail.fiAreaCode ?? 0
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
    var compoundNameAlias: String { dcCompound.fvNameAlias ?? "" }
    var compoundLandAreaString: String { dcCompound.fbLandArea ?? "" }
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
    var compoundBusinessMating: String { dcCompound.fvBusinessMating ?? "" }
    var compoundHospital: String { dcCompound.fvHospital ?? "" }
    var compoundFinaceOrg: String { dcCompound.fvFinaceOrg ?? "" }
    var compoundStadium: String { dcCompound.fvStadium ?? "" }
    var compoundAdminOffice: String { dcCompound.fvAdminOffice ?? "" }
    var compoundRelaxSquare: String { dcCompound.fvRelaxSquare ?? ""}
    var compoundKindergarten: String { dcCompound.fvKindergarten ?? ""}
    var compoundPrimarySchool: String { dcCompound.fvPrimarySchool ?? "" }
    var compoundMiddleSchool: String { dcCompound.fvMiddleSchool ?? "" }
    var compoundUniversity: String { dcCompound.fvUniversity ?? "" }
    var compoundStreetMark: String { dcCompound.fvStreetMark ?? "" }
    var compoundAddrMark: String { dcCompound.fvAddrMark ?? "" }
    var compoundAdjacentEstate: String { dcCompound.fvAdjacentEstate ?? "" }
    var compoundLandNo: String { dcCompound.fvLandNo ?? "" }
    var compoundBusinessDistrict: String { dcCompound.fvBusinessDistrict ?? "" }
    var compoundBusinessLevel: String { DictType.fv_business_level.label(of: dcCompound.fvBusinessLevel ?? "") ?? "" }
    var compoundPlate: String { dcCompound.fvPlate ?? "" }
    var compoundResidentialArea: String { dcCompound.fbResidentialArea ?? "" }
    var compoundBuildingNumber: String { dcCompound.fiBuildingNumber ?? "" }
    var compoundBuildingDesc: String { dcCompound.fvBuildingDesc ?? "" }
    var compoundBuildingType: String { dcCompound.fvBuildingType ?? "" }
    var compoundBuildingStructure: String { DictType.buildingStructure.label(of: dcCompound.fvBuildingStructure ?? "") ?? "" }
    var compoundBuildingDensity: String { dcCompound.fvBuildingDensity ?? "" }
    var compoundGreeningRate: String { dcCompound.fvGreeningRate ?? "" }
    var compoundVolumeRate: String { "\(dcCompound.fbVolumeRate ?? 0)" }
    var compoundOutsideMainRoad: String { dcCompound.fvOutsideMainRoad ?? "" }
    var compoundInternalRoad: String { dcCompound.fvInternalRoad ?? "" }
    var compoundBusStopDistance: String { dcCompound.fbBusStopDistance ?? "" }
    var compoundBusLineNumber: String { dcCompound.fiBusLineNumber ?? "" }
    var compoundSubwayDistance: String { dcCompound.fbSubwayDistance ?? "" }
    var compoundClubServise: String { dcCompound.fvClubServise ?? "" }
    var compoundSportStructure: String { dcCompound.fvSportStructure ?? "" }
    var compoundFallowStructure: String { dcCompound.fvFallowStructure ?? "" }
    var compoundParking: String { dcCompound.fvParking ?? "" }
    var compoundParkingType: String { dcCompound.fvParkingType ?? "" }
    var compoundParkingRate: String { dcCompound.fvParkingRate ?? "" }
    var compoundBaseFacility: String { dcCompound.fvBaseFacility ?? "" }
    var compoundGetHouseRate: String { dcCompound.fvGetHouseRate ?? "" }
    var compoundCbdDistance: String { dcCompound.fvCbdDistance ?? "" }
    var compoundRoadLevel: String { dcCompound.fvRoadLevel ?? "" }
    var compoundOutEnvi: String { dcCompound.fvOutEnvi ?? "" }
    var compoundInEnvi: String { dcCompound.fvInEnvi ?? "" }
    var compoundRoadEnvi: String { dcCompound.fvRoadEnvi ?? "" }
    var compoundPollution: String { dcCompound.fvPollution ?? "" }
    var compoundPollution2: String { dcCompound.fvPollution2 ?? "" }
    var compoundOtherPolu: String { dcCompound.fvOtherPolu ?? "" }
    var compoundOtherFactor: String { dcCompound.fvOtherFactor ?? "" }
    var compoundIsClose: String { DictType.IsClose(rawValue: dcCompound.fvIsClose ?? "")?.label ?? ""}
    var compoundPropertyManageType: String { DictType.fv_property_manage_type.label(of: dcCompound.fvPropertyManageType ?? "") ?? "" }
    var compoundPropertyCompany: String { dcCompound.fvPropertyCompany ?? "" }
    var compoundPropertyFee: String { dcCompound.fvPropertyFee ?? "" }
    var compoundBuildingArea: String { "\(dcCompound.fbBuildingArea ?? 0)" }
    var compoundBussinessType: String { DictType.fv_business_type.label(of: dcCompound.fvBussinessType ?? "") ?? "" }
    var compoundStartHouseRules: String { dcCompound.fvStartHouseRules ?? "" }
    var compoundEndHouseRules: String { dcCompound.fvEndHouseRules ?? "" }
    var compoundBusinessRating: String { dcCompound.fvBusinessRating ?? "" }
    var compoundBusinessProspects: String { dcCompound.fvBusinessProspects ?? "" }
    var compoundBuildingGeneralSituation: String { dcCompound.fvBuildingGeneralSituation ?? "" }
    var compoundHouseCount: String { dcCompound.fiHouseCount ?? "" }
    var compoundBusinessDistance: String { dcCompound.fvBusinessDistance ?? "" }
    var compoundHotelRestaurant: String { dcCompound.fvHotelRestaurant ?? "" }
    var compoundEduHospital: String { dcCompound.fvEduHospital ?? "" }
    var compoundLifeMating: String { dcCompound.fvLifeMating ?? "" }
    var compoundEduComplete: String { dcCompound.fvEduComplete ?? "" }
    var compoundBusComplete: String { dcCompound.fvBusComplete ?? "" }
    var compoundHospitalComplete: String { dcCompound.fvHospitalComplete ?? "" }
    var compoundAllAround: String { dcCompound.fvAllAround ?? "" }
    var compoundAreaLocation: String { dcCompound.fvAreaLocation ?? "" }
    var compoundDistanceCityCentre: String { dcCompound.fvDistanceCityCentre ?? "" }
    var compoundIndustrialSize: String { dcCompound.fbIndustrialSize ?? "" }
    var compoundParkFeatures: String { dcCompound.fvParkFeatures ?? "" }
    var compoundIndustrialConcentrationRating: String { DictType.fv_industrial_concentration_rating.label(of: dcCompound.fvIndustrialConcentrationRating ?? "") ?? "" }
    var compoundParkKeyEnterprises: String { dcCompound.fvParkKeyEnterprises ?? "" }
    var compoundIndustryLimit: String { dcCompound.fvIndustryLimit ?? "" }
    var compoundCommunityName: String { dcCompound.fvCommunityName ?? "" }

    
    var buildingLevelDecorate: DictType.LevelDecorate? {
        DictType.LevelDecorate(rawValue: dcBuilding.fvLevelDecorateFk ?? "" )
    }
    
    var imageList: [String] {
        networkRoomDetail.buildingImageList.compactMap { $0.fvUrl }
        +
        networkRoomDetail.compoundImageList.compactMap { $0.fvUrl }
    }
    
    var coverImg: String {
        networkRoomDetail.compoundImageList.first?.fvUrl
        ?? networkRoomDetail.buildingImageList.first?.fvUrl
        ?? "https://image.xuboren.com/image/2023/07/27/e94490b018a14aa3a1d8f97a3d8b0cfa.jpg"
    }
    
    var coordinate: Coordinate? {
        get {
            do {
                guard let pois = dcCompound.fvPois,
                      let data = pois.data(using: .utf8)
                else { return nil }
                return try data.decoded() as Coordinate
            } catch {
                return nil
            }
        }
        set(value) {
        }
    }
    
    private var fvPois: Data? {
        dcCompound.fvPois?.data(using: .utf8)
    }
    
    var mapViewCoordinate: MapViewCoordinate? {
        guard let data = fvPois else { return nil }
        
        do {
            switch estateType {
            case .industrialFactory:
                return try .plane(data.decoded() as [Coordinate])
                
            case .shopStreet:
                fallthrough
            case .landingRoom:
                return try .line(data.decoded() as [Coordinate])
                
            default:
                return try .point([data.decoded() as Coordinate])
            }
        } catch {
            print("decode fvPois FAILED!!!, estatType:\(estateTypeString), fvPois:\(dcCompound.fvPois)")
            return nil
        }
    }
    
    var queryExplain: String {
        networkRoomDetail.dcCompound.fvQueryExplain ?? nilText
    }
}

