//
//  data+ReportSheet.swift
//  rps-ios
//
//  Created by serika on 2023/11/28.
//

import Foundation


struct ReportSheet {
    var networkReportSheet: Linkman.NetworkReportSheet = [:]
    
    init(networkReportSheet: Linkman.NetworkReportSheet) {
        self.networkReportSheet = networkReportSheet
        let floor: String = value(for: "fvInFloor")
        let l = floor.components(separatedBy: "-")
        if l.count == 2 {
            self.beginFloor = Int(l[0])
            self.endFloor = Int(l[1])
        }
    }
    
    init() {
        self.init(networkReportSheet: [:])
    }
    
    var certificateAddress: String {
        get { value(for: "fvPropertyCertificateAddr" ) }
        set(value) { set(value, for: "fvPropertyCertificateAddr") }
    }
    var estateType: DictType.EstateType? {
        get { DictType.EstateType(rawValue: value(for: "fvEstateType")) }
        set(value) {
            if let value = value {
                set(value.dictKey, for: "fvEstateType")
            }
        }
    }
    var clientName: String {
        get { value(for: "fvWtNickName") }
        set(value) { set(value, for: "fvWtNickName")}
    }
    var phone: String {
        get { value(for: "fvWtPhone") }
        set(value) { set(value, for: "fvWtPhone") }
    }
    var purpose: DictType.ValuationPurpose? {
        get { DictType.ValuationPurpose(rawValue: value(for: "fvValuationPurpose")) }
        set(value) { set(value?.dictKey ?? "", for: "fvValuationPurpose") }
    }
    
    var provinceCode: Int {
        get { value(for: "fiProvinceCode") ?? 0 }
        set(value) { set(value, for: "fiProvinceCode") }
    }
    var cityCode: Int {
        get { value(for: "fiCityCode") ?? 0 }
        set(value) { set(value, for: "fiCityCode") }
    }
    var areaCode: Int {
        get { value(for: "fiAreaCode") ?? 0 }
        set(value) { set(value, for: "fiAreaCode") }
    }
    var provinceName: String {
        get { value(for: "fvProvinceName") }
        set(value) { set(value, for: "fvProvinceName") }
    }
    var cityName: String {
        get { value(for: "fvCityName") }
        set(value) { set(value, for: "fvCityName") }
    }
    var areaName: String {
        get { value(for: "fvAreaName") }
        set(value) { set(value, for: "fvAreaName") }
    }
    var address: String {
        get { value(for: "fvPropertyRightAddr") }
        set(value) { set(value, for: "fvPropertyRightAddr") }
    }
    var buildingArea: String {
        get { value(for: "fbBuildingArea") }
        set(value) { set(value, for: "fbBuildingArea") }
    }
    var buildingYear: Int? {
        get { value(for: "fdCompletionDate") }
        set(value) { set(value, for: "fdCompletionDate") }
    }
    var structure: DictType.BuildingStructure? {
        get { DictType.BuildingStructure(rawValue: value(for: "fvBuildingStructure")) }
        set(value) { set(value?.dictKey ?? "", for: "fvBuildingStructure") }
    }
    var landArea: String {
        get { value(for: "fdLandArea") }
        set(value) { set(value, for: "fdLandArea") }
    }
    var beginFloor: Int?
    var endFloor: Int?
    var valuationDate: String {
        get { value(for: "fvValuationDate") }
        set(value) { set(value, for: "fvValuationDate") }
    }
    var price: Int? {
        get {
            if let price: Int = value(for: "fvValuationPrice") {
                return price / 10000
            } else {
                return nil
            }
        }
        set(value) {
            if let value = value {
                set(value * 10000, for: "fvValuationPrice")
            }
        }
    }
    var totalPrice: Int? {
        get { 
            if let price: Int = value(for: "fvValuationTotalPrice") {
                return price / 10000
            } else {
                return nil
            }
        }
        set(value) {
            if let value = value {
                set(value * 10000, for: "fvValuationTotalPrice")
            }
        }
    }
    var owner: String {
        get { value(for: "fvOwnershipHouseOwner") }
        set(value) { set(value, for: "fvOwnershipHouseOwner") }
    }
    var ownerNumber: String {
        get { value(for: "fvOwnershipHouseNumber") }
        set(value) { set(value, for: "fvOwnershipHouseNumber") }
    }
    var housingUse: DictType.HousingUse? {
        get { DictType.HousingUse(rawValue: value(for: "fvDesignPurposeOfHouse")) }
        set(value) { set(value?.dictKey ?? "", for: "fvDesignPurposeOfHouse") }
    }
    var facing: DictType.BuildDirection? {
        get { DictType.BuildDirection(rawValue: value(for: "fvBuildDirection")) }
        set(value) { set(value?.dictKey ?? "", for: "fvBuildDirection") }
    }
    var landSe: DictType.LandSe? {
        get { DictType.LandSe(rawValue: value(for: "fvClassToUse")) }
        set(value) { set(value?.dictKey ?? "", for: "fvClassToUse") }
    }
    var landUser: DictType.LandUser? {
        get { DictType.LandUser(rawValue: value(for: "fvUseRightType")) }
        set(value) { set(value?.dictKey ?? "", for: "fvUseRightType") }
    }
    var landEndDate: String {
        get { value(for: "fvLandEndDate") }
        set(value) { set(value, for: "fvLandEndDate") }
    }
    var landNumber: String {
        get { value(for: "fvLandUseRightNumber") }
        set(value) { set(value, for: "fvLandUseRightNumber") }
    }
    var northTo: String {
        get { value(for: "fvToNorth") }
        set(value) { set(value, for: "fvToNorth") }
    }
    var southTo: String {
        get { value(for: "fvToSouth") }
        set(value) { set(value, for: "fvToSouth") }
    }
    var eastTo: String {
        get { value(for: "fvToEast") }
        set(value) { set(value, for: "fvToEast") }
    }
    var westTo: String {
        get { value(for: "fvToWest") }
        set(value) { set(value, for: "fvToWest") }
    }
    var traffic: String {
        get { value(for: "fvTraffic") }
        set(value) { set(value, for: "fvTraffic") }
    }
    var publicFacilities: String {
        get { value(for: "fvPublicFacilities") }
        set(value) { set(value, for: "fvPublicFacilities") }
    }
    var decoration: DictType.Decoration? {
        get { DictType.Decoration(rawValue: value(for: "fvDecoreate")) }
        set(value) { set(value?.dictKey ?? "", for: "fvDecoreate") }
    }
    var levelDecorate: DictType.LevelDecorate? {
        get { DictType.LevelDecorate(rawValue: value(for: "fvDecoreate")) }
        set(value) { set(value?.dictKey ?? "", for: "fvDecoreate") }
    }
    var buildingNewDegree: Double? {
        get { value(for: "fvBuildingNewDegree") }
        set(value) { set(value, for: "fvBuildingNewDegree") }
    }
    var houseTransferee: String {
        get { value(for: "fvHouseTransferee") }
        set(value) { set(value, for: "fvHouseTransferee") }
    }
    var houseTransferAmount: Int? {
        get { value(for: "fvHouseTransferAmount") }
        set(value) { set(value, for: "fvHouseTransferAmount") }
    }
    var propertyCoOwnershipSituation: DictType.CoOwnershipSituation? {
        get { DictType.CoOwnershipSituation(rawValue: value(for: "fvPropertyCoOwnershipSituation")) }
        set(value) { set(value?.dictKey ?? "", for: "fvPropertyCoOwnershipSituation") }
    }
    var propertyCoOwnership: String {
        get { value(for: "fvPropertyCoOwnership") }
        set(value) { set(value, for: "fvPropertyCoOwnership") }
    }
    var jointOwnershipCertificateNumber: String {
        get { value(for: "fvJointOwnershipCertificateNumber") }
        set(value) { set(value, for: "fvJointOwnershipCertificateNumber") }
    }
    var spatialLayout: DictType.SpatialLayout? {
        get { DictType.SpatialLayout(rawValue: value(for: "fvSpatialLayout")) }
        set(value) { set(value?.dictKey ?? "", for: "fvSpatialLayout") }
    }
    var houseUse: String {
        get { value(for: "fvHouseUseStatusQuo") }
        set(value) { set(value, for: "fvHouseUseStatusQuo") }
    }
    var compensation: String {
        get { value(for: "fvStatutoryPriorityRightToCompensation") }
        set(value) { set(value, for: "fvStatutoryPriorityRightToCompensation") }
    }
    var bkLander: String {
        get { value(for: "fvBkLender") }
        set(value) { set(value, for: "fvBkLender") }
    }
    var bkLandType: String {
        get { value(for: "fvBkLendType") }
        set(value) { set(value, for: "fvBkLendType") }
    }
    var organ: String {
        get { value(for: "fvWtOrgan") }
        set(value) { set(value, for: "fvWtOrgan") }
    }
    var organDept: String {
        get { value(for: "fvWtOrganDept") }
        set(value) { set(value, for: "fvWtOrganDept") }
    }
    var bankBranchCode: String {
        get { value(for: "fvBkBankBranchCode") }
        set(value) { set(value, for: "fvBkBankBranchCode") }
    }
    var comment: String {
        get { value(for: "fvWtRemark") }
        set(value) { set(value, for: "fvWtRemark") }
    }
    var images: [RpsImage] = []
}

private extension ReportSheet {
    func value(for key: String) -> String {
        networkReportSheet[key] as? String ?? ""
    }
    
    mutating func set(_ value: String, for key: String) {
        if !value.isEmpty {
            networkReportSheet[key] = value
        } else {
            networkReportSheet.removeValue(forKey: key)
        }
    }
    
    func value(for key: String) -> Int? {
        networkReportSheet[key] as? Int
    }
    
    mutating func set(_ value: Int?, for key: String) {
        if let value = value {
            networkReportSheet[key] = value
        } else {
            networkReportSheet.removeValue(forKey: key)
        }
    }
    
    func value(for key: String) -> Double? {
        networkReportSheet[key] as? Double
    }
    
    mutating func set(_ value: Double?, for key: String) {
        if let value = value {
            networkReportSheet[key] = value
        } else {
            networkReportSheet.removeValue(forKey: key)
        }
    }
}
