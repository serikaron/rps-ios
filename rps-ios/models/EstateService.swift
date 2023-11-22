//
//  EstateService.swift
//  rps-ios
//
//  Created by serika on 2023/11/10.
//

import Foundation

struct SearchResult {
    let id: String
    let roomName: String?
    let compoundName: String?
    let completionDate: String?
    let estateType: String?
    let estateTypeLabel: String?
    let compoundNameAlias: String?
    let address: String?
    let picUrls: String?
    let comId: Int?
    let areacode: Int?
    let buildingId: Int?
    let floor: String?
}
typealias SearchResultList = [SearchResult]

@MainActor
class EstateService: ObservableObject {
    private var fuzzySearchTask: Task<Void, Never>?
    @Published var fuzzySearchResult: SearchResultList = []
    
    var isPreview = false
    
    func fuzzySearch(keyword: String) {
        guard !keyword.isEmpty else {
            fuzzySearchResult = []
            return
        }
        
        fuzzySearchTask?.cancel()
        
        fuzzySearchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                if Task.isCancelled {
                    fuzzySearchResult = []
                    return
                }
                
                fuzzySearchResult = await _searchRoom(keyword: keyword)
            } catch {
                fuzzySearchResult = []
            }
        }
    }
    
    private func _searchRoom(keyword: String) async -> SearchResultList {
        
        do {
            let rsp = try await Linkman.shared.fuzzySearch(keyword: keyword)
            return .fromNetwork(rsp)
        } catch {
            return []
        }
    }
    
    @Published var exactSearchResult: SearchResultList = []
    private struct SearchParam {
        let keyword: String
        var pageNum = 1
        let pageSize = 10
        var finished = false
    }
    private var searchParam = SearchParam(keyword: "")
    
    func exactSearch(keyword: String) async {
        if keyword.isEmpty { return }
        
        if searchParam.keyword != keyword {
            searchParam = SearchParam(keyword: keyword)
        } else {
            searchParam.pageNum += 1
        }
        
        if searchParam.finished { return }
        
        
        do {
            let rsp = try await Linkman.shared.exactSearch(keyword: keyword, pageSize: searchParam.pageSize, pageNum: searchParam.pageNum)
            let l = SearchResultList.fromNetwork(rsp.records)
            if searchParam.pageNum == 1 {
                exactSearchResult = l
            } else {
                exactSearchResult.append(contentsOf: l)
            }
            searchParam.finished = exactSearchResult.count >= rsp.total || searchParam.pageSize > rsp.size
        } catch {
            print("excatSearch ERROR: \(error)")
        }
    }
    
    @Published var buildings: Buildings = []
    
    func getBuildings(comId: Int, estateType: String, pageSize: Int, pageNum: Int) async -> (total: Int, size: Int, buildings: Buildings) {
        print("getBuildings \(comId) - \(estateType) - \(pageSize) - \(pageNum)")
        guard comId != 0, !estateType.isEmpty else {
            return (0, 0, [])
        }
        
        do {
            let r = try await Linkman.shared.getBuildings(compoundId: comId, estateType: estateType, pageSize: pageSize, pageNum: pageNum)
            return (r.total, r.size, r.records)
        } catch {
            print("getBuildings FAILED: \(error)")
            return (0, 0, [])
        }
    }
    
    @Published var floors: Floors = .empty
    func getFloors(buildingName: String, buildingId: Int, estateType: String, areaCode: Int) async {
        do {
            let roomCount = try await Linkman.shared.getRoomCount(estateType: estateType, buildingId: buildingId)
            
            let rsp = try await Linkman.shared.getBuildingFloors(buildingId: buildingId, estateType: estateType, areaCode: areaCode)
            let units = rsp.unitInfoResponseList.sorted { $0.order ?? "" < $1.order ?? "" }
            let keys = units.compactMap { $0.keys }
            let floors = rsp.floorData.map { floor in
                Floor(
                    name: floor.louceng ?? "",
                    rooms: keys.compactMap { key -> Room? in
                        guard let l = floor.units[key],
                              !l.items.isEmpty
                        else { return nil }
                        
                        let r = l.items[0]
                        return Room(name: roomCount == 0 ?
                                    "\(String(format: "%02d", r.fiFloorNum ?? 0))\(r.fvRoomNum ?? "")" :
                                        r.fvRoomName ?? "",
                                    familyRoomName: r.fvFamilyRoomName ?? "",
                                    areaCode: r.fiAreaCode ?? 0,
                                    estateType: r.fvEstateType ?? "",
                                    buildingId: r.fiBuildingId ?? 0,
                                    floor: r.fvInFloor ?? ""
                        )
                    }
                )
            }
            self.floors = Floors(buildingName: buildingName, unitTitles: units.compactMap { $0.unitName }, floors: floors)
        } catch {
            print("getFloors FAILED: \(error)")
            floors = Floors.empty
        }
    }
    
//    @Published var roomDetail: RoomDetail = .empty
    func getRoomDetail(estateType: String, areaCode: Int, familyRoomName: String, buildingId: Int, orgId: Int) async -> RoomDetail {
//        print("getRoomDetail, estateType:\(estateType), areaCode:\(areaCode), familyRoomName:\(familyRoomName), buildingId:\(buildingId)")
//        roomDetail = .empty
        do {
            let roomCount = try await Linkman.shared.getRoomCount(estateType: estateType, buildingId: buildingId)
            let rsp = try await Linkman.shared.getRoomDetail(estateType: estateType, areaCode: areaCode, familyRoomName: familyRoomName, orgId: orgId)
            return RoomDetail(networkRoomDetail: rsp, roomCount: roomCount)
        } catch {
            print("getRoomDetail FAILED: \(error)")
            return .empty
        }
    }
    
    func createInquiry(buildingId: Int, estateType: String, areaCode: Int, searchAddr: String, orgId: Int) async -> Inquiry {
        do {
            let r = try await Linkman.shared.createInquiry(buildingId: buildingId, estateType: estateType, areaCode: areaCode, searchAddr: searchAddr, orgId: orgId)
            return Inquiry(networkInquiry: r)
        } catch {
            print("createInquiry FAILED: \(error)")
            return .empty
        }
    }
    
    func inquire(inquiry: Inquiry) async -> Inquiry {
        do {
            let r = try await Linkman.shared.inquire(inquiry: inquiry.networkInquiry)
            return Inquiry(networkInquiry: r)
        } catch {
            print("inquire FAILED: \(error)")
            return .empty
        }
    }
    
    func inquireDetail(inquiry: Inquiry) async -> Inquiry {
        do {
            let r = try await Linkman.shared.inquireDetail(inquiry: inquiry.networkInquiry)
            return Inquiry(networkInquiry: r)
        } catch {
            print("inquireDetail FAILED: \(error)")
            return .empty
        }
    }
    
    
    func getCaseList(compoundId: Int, estateType: String, price: Double) async -> [ReferenceCase] {
        if isPreview { return ReferenceCase.moclList }
        
        do {
            let rsp = try await Linkman.shared.getRoomCases(compoundId: compoundId, estateType: estateType, price: price)
            return rsp.map { c in
                ReferenceCase(
                    tradeType: c.fiTradeType == nil ? "" :
                        DictType.TradeType(rawValue: "\(c.fiTradeType!)")?.label ?? "",
                    date: c.fvCaseTime ?? "",
                    caseAddress: c.fvCaseAddress ?? "",
                    decorate: DictType.Decoration(rawValue: c.fvDecoration)?.label ?? "",
                    floor: c.fvInFloor ?? "",
                    price: c.fbPrice == nil ? "" : "\(c.fbPrice! / 10000)",
                    totalPrice: c.fbTotalPrice == nil ? "" : "\(c.fbTotalPrice! / 10000)",
                    area: c.fbArea == nil ? "" : "\(c.fbArea!)",
                    compoundAddress: c.fvCompoundMatchAddress ?? "",
                    totalFloor: c.fiTotalFloor == nil ? "0" : "\(c.fiTotalFloor!)"
                )
            }
        } catch {
            print("getCaseList FAILED: \(error)")
            return []
        }
    }
    
    func getBaseCompoundPrice(compoundId: Int, estateType: String) async -> Double {
        do {
            let timeString = Date().toString(format: "YYYY-MM")
            let rsp = try await Linkman.shared.getCompoundCurve(compoundId: compoundId, startTime: timeString, endTime: timeString, estateType: estateType)
            guard !rsp.isEmpty else { return 0 }
            return rsp[0].price ?? 0
        } catch {
            print("getBaseCompoundPrice FAILED: \(error)")
            return 0
        }
    }
    
    func addInquiry(sheet: InquirySheet, state: Int) async -> Bool {
        guard let fvEstateType = sheet.estateType,
              sheet.provinceCode != 0,
              sheet.cityCode != 0,
              sheet.areaCode != 0,
              !sheet.address.isEmpty,
              !sheet.contact.isEmpty,
              !sheet.phone.isEmpty,
              sheet.buildingArea != 0,
              let fvValuationPurpose = sheet.purpose,
              !sheet.valuationDate.isEmpty
        else {
            Box.sendError("请完成必填信息")
            return false
        }
        
        var dict = [String: Any]()
        dict["fiState"] = state
        
        dict["fvEstateType"] = fvEstateType.dictKey
        dict["fiProvinceCode"] = sheet.provinceCode
        dict["fvProvinceName"] = sheet.provinceName
        dict["fiCityCode"] = sheet.cityCode
        dict["fvCityName"] = sheet.cityName
        dict["fiAreaCode"] = sheet.areaCode
        dict["fvAreaName"] = sheet.areaName
        dict["fvPropertyRightAddr"] = sheet.address
        dict["fvContact"] = sheet.contact
        dict["fvContactPhone"] = sheet.phone
        dict["fbBuildingArea"] = sheet.buildingArea
        dict["fvValuationPurpose"] = fvValuationPurpose.dictKey
        dict["fvValuationDate"] = sheet.valuationDate
        
        if let structure = sheet.structure {
            dict["fvBuildingStructure"] = structure.dictKey
        }
        if let landArea = sheet.landArea {
            dict["fbLandArea"] = landArea
        }
        if !sheet.buildingYear.isEmpty {
            dict["fvBuildingYear"] = sheet.buildingYear
        }
        if let upperFloor = sheet.upperFloor {
            dict["fiLandUpperCount"] = upperFloor
        }
        if let underFloor = sheet.underFloor {
            dict["fiLandLowerCount"] = underFloor
        }
        if let beginFloor = sheet.beginFloor {
            dict["fiBeginFloor"] = beginFloor
        }
        if let endFloor = sheet.endFloor {
            dict["fiEndFloor"] = endFloor
        }
        if !sheet.telephone.isEmpty {
            dict["fvFixedTelephone"] = sheet.telephone
        }
        if !sheet.custodian.isEmpty {
            dict["fvBusinessCustodian"] = sheet.custodian
        }
        
        do {
            var imageList = [[String: Any]]()
            for image in sheet.images {
                let uploadRsp = try await Linkman.shared.upload(image: image.image, filename: image.filename)
                var imageDict = [String: Any]()
                imageDict["fvOssId"] = uploadRsp.ossId
                imageDict["originalName"] = uploadRsp.originalName
                imageDict["fdCreateTime"] = uploadRsp.createTime
                imageDict["fvOssUrl"] = uploadRsp.url
                imageDict["fileSuffix"] = uploadRsp.fileSuffix
                imageList.append(imageDict)
            }
            dict["fileList"] = imageList
            
            try await Linkman.shared.addInquiry(inquiryDict: dict)
            return true
        } catch {
            print("addInquiry FAILED!!! \(error)")
            return false
        }
    }
    
    func addReport(sheet: ReportSheet, state: Int) async -> Bool {
        guard let estateType = sheet.estateType,
              !sheet.certificateAddress.isEmpty,
              !sheet.clientName.isEmpty,
              !sheet.phone.isEmpty,
              let purpose = sheet.purpose
        else {
            Box.sendError("请完成必填信息")
            return false
        }
        
        var dict = [String: Any]()
        dict["fiReportState"] = state
        
        dict["fvPropertyCertificateAddr"] = sheet.certificateAddress
        dict["fvEstateType"] = estateType.dictKey
        dict["fvWtNickName"] = sheet.clientName
        dict["fvWtPhone"] = sheet.phone
        dict["fvValuationPurpose"] = purpose.dictKey
        
        if sheet.provinceCode != 0 {
            dict["fiProvinceCode"] = sheet.provinceCode
            dict["fvProvinceName"] = sheet.provinceName
        }
        if sheet.cityCode != 0 {
            dict["fiCityCode"] = sheet.cityCode
            dict["fvCityName"] = sheet.cityName
        }
        if sheet.areaCode != 0 {
            dict["fiAreaCode"] = sheet.areaCode
            dict["fvAreaName"] = sheet.areaName
        }
        if !sheet.address.isEmpty {
            dict["fvPropertyRightAddr"] = sheet.address
        }
        if let area = sheet.buildingArea {
            dict["fbBuildingArea"] = area
        }
        if let year = sheet.buildingYear {
            dict["fdCompletionDate"] = "\(year)"
        }
        if let structure = sheet.structure {
            dict["fvBuildingStructure"] = structure.dictKey
        }
        if let landArea = sheet.landArea {
            dict["fdLandArea"] = landArea
        }
        if let beginFloor = sheet.beginFloor,
           let endFloor = sheet.endFloor {
            dict["fvInFloor"] = "\(beginFloor)-\(endFloor)"
        }
        if !sheet.valuationDate.isEmpty {
            dict["fvValuationDate"] = sheet.valuationDate
        }
        if let price = sheet.price {
            dict["fvValuationPrice"] = "\(price * 10000)"
        }
        if let totalPrice = sheet.totalPrice {
            dict["fvValuationTotalPrice"] = "\(totalPrice * 10000)"
        }
        if !sheet.owner.isEmpty {
            dict["fvOwnershipHouseOwner"] = sheet.owner
        }
        if !sheet.ownerNumber.isEmpty {
            dict["fvOwnershipHouseNumber"] = sheet.ownerNumber
        }
        if let housingUse = sheet.housingUse {
            dict["fvDesignPurposeOfHouse"] = housingUse.dictKey
        }
        if let facing = sheet.facing {
            dict["fvBuildDirection"] = facing.dictKey
        }
        if let landSe = sheet.landSe {
            dict["fvClassToUse"] = landSe.dictKey
        }
        if let landUser = sheet.landUser {
            dict["fvUseRightType"] = landUser.dictKey
        }
        if !sheet.landEndDate.isEmpty {
            dict["fvLandEndDate"] = sheet.landEndDate
        }
        if !sheet.landNumber.isEmpty {
            dict["fvLandUseRightNumber"] = sheet.landNumber
        }
        if !sheet.northTo.isEmpty {
            dict["fvToNorth"] = sheet.northTo
        }
        if !sheet.southTo.isEmpty {
            dict["fvToSouth"] = sheet.southTo
        }
        if !sheet.eastTo.isEmpty {
            dict["fvToEast"] = sheet.eastTo
        }
        if !sheet.westTo.isEmpty {
            dict["fvToWest"] = sheet.westTo
        }
        if !sheet.traffic.isEmpty {
            dict["fvTraffic"] = sheet.traffic
        }
        if !sheet.publicFacilities.isEmpty {
            dict["fvPublicFacilities"] = sheet.publicFacilities
        }
        if let decoration = sheet.decoration {
            dict["fvDecoreate"] = decoration.dictKey
        }
        if let levelDecorate = sheet.levelDecorate {
            dict["fvDecoreate"] = levelDecorate.dictKey
        }
        if let degree = sheet.buildingNewDegree {
            dict["fvBuildingNewDegree"] = "\(degree)"
        }
        if !sheet.houseTransferee.isEmpty {
            dict["fvHouseTransferee"] = sheet.houseTransferee
        }
        if let houseTransferAmount = sheet.houseTransferAmount {
            dict["fvHouseTransferAmount"] = "\(houseTransferAmount)"
        }
        if let propertyCoOwnershipSituation = sheet.propertyCoOwnershipSituation {
            dict["fvPropertyCoOwnershipSituation"] = propertyCoOwnershipSituation.dictKey
        }
        if !sheet.propertyCoOwnership.isEmpty {
            dict["fvPropertyCoOwnership"] = sheet.propertyCoOwnership
        }
        if !sheet.jointOwnershipCertificateNumber.isEmpty {
            dict["fvJointOwnershipCertificateNumber"] = sheet.jointOwnershipCertificateNumber
        }
        if let spatialLayout = sheet.spatialLayout {
            dict["fvSpatialLayout"] = spatialLayout.dictKey
        }
        if !sheet.houseUse.isEmpty {
            dict["fvHouseUseStatusQuo"] = sheet.houseUse
        }
        if !sheet.compensation.isEmpty {
            dict["fvStatutoryPriorityRightToCompensation"] = sheet.compensation
        }
        if !sheet.bkLander.isEmpty {
            dict["fvBkLender"] = sheet.bkLander
        }
        if !sheet.bkLandType.isEmpty {
            dict["fvBkLendType"] = sheet.bkLandType
        }
        if !sheet.organ.isEmpty {
            dict["fvWtOrgan"] = sheet.organ
        }
        if !sheet.organDept.isEmpty {
            dict["fvWtOrganDept"] = sheet.organDept
        }
        if !sheet.bankBranchCode.isEmpty {
            dict["fvBkBankBranchCode"] = sheet.bankBranchCode
        }
        if !sheet.comment.isEmpty {
            dict["fvWtRemark"] = sheet.comment
        }

        
        do {
            var imageList = [[String: Any]]()
            for image in sheet.images {
                let uploadRsp = try await Linkman.shared.upload(image: image.image, filename: image.filename)
                var imageDict = [String: Any]()
                imageDict["fvReportOssId"] = uploadRsp.ossId
                imageDict["fdCreateTime"] = uploadRsp.createTime
                imageDict["fvReportOssUrl"] = uploadRsp.url
                imageDict["imgType"] = uploadRsp.fileSuffix
                imageList.append(imageDict)
            }
            dict["fileList"] = imageList
            
            try await Linkman.shared.addReport(reportDict: dict)
            return true
        } catch {
            print("addReport FAILED!!! \(error)")
            return false
        }
    }
    
    func getRecords(pageNum: Int, pageSize: Int) async -> RecordsResult {
        if isPreview {
            return RecordsResult(total: 10, current: 1, records: [.mock])
        }
        
        do {
            let rsp = try await Linkman.shared.getRecords(pageNum: pageNum, pageSize: pageSize)
            return RecordsResult(
                total: rsp.total, current: rsp.current,
                records: rsp.records.compactMap { r -> Record? in
                    guard let inquiryType = InquiryType(rawValue: r.fiType),
                          let estateType = DictType.EstateType(rawValue: r.fvEstateType ?? ""),
                          let inquiryState = InquiryState(rawValue: r.fiState),
                          let downloadState = DownloadState(rawValue: r.downloadState ?? 1)
                    else { return nil }
                    return Record(
                        id: r.id ?? 0,
                        imageURL: r.fvCoverImg ?? "",
                        inquiryType: inquiryType,
                        district: r.fvAreaName ?? "",
                        estateType: estateType,
                        address: r.fvPropertyRightAddr ?? "",
                        clientName: r.fvInquiryUserName ?? "",
                        valuationDate: r.fvValuationDate ?? "",
                        inquiryState: inquiryState,
                        downloadState: downloadState,
                        totalPrice: r.fvValuationTotalPrice ?? "",
                        price: r.fvValuationPrice ?? "",
                        area: r.fbBuildingArea == nil ? "" : "\(r.fbBuildingArea!)")
                })
        } catch {
            print("getRecords FAILED!!! \(error)")
            return RecordsResult(total: 0, current: 0, records: [])
        }
    }
}

extension SearchResult {
    static func mock(num: Int) -> SearchResult {
        SearchResult(id: "\(num)",
                     roomName: "roomName-\(num)",
                     compoundName: "compoundName-\(num)",
                     completionDate: "completionDate-\(num)",
                     estateType: "estateType-\(num)",
                     estateTypeLabel: "estateTypeLabel-\(num)",
                     compoundNameAlias: "compoundNameAlias-\(num)",
                     address: "address-\(num)",
                     picUrls: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg",
                     comId: 1,
                     areacode: 300106,
                     buildingId: 1,
                     floor: "1-1"
        )
    }
    
    static func fromNetwork(_ item: Linkman.NetworkSearchResult) -> SearchResult {
        SearchResult(
            id: item.id,
            roomName: item.fvFamilyRoomName,
            compoundName: item.fvCompoundName,
            completionDate: item.fvCompletionDate,
            estateType: item.fvEstateType,
            estateTypeLabel: DictType.estate.label(of: item.fvEstateType ?? "") ?? "",
            compoundNameAlias: item.fvNameAlias,
            address: item.fvStreetMark,
            picUrls: item.picUrls,
            comId: item.fiCompoundId,
            areacode: item.fiAreaCode,
            buildingId: item.fiBuildingId,
            floor: item.fvInFloor
        )
    }
}

extension SearchResultList {
    static func fromNetwork(_ networkList: [Linkman.NetworkSearchResult]) -> SearchResultList {
        var out: SearchResultList = []
        for item in networkList {
            out.append(SearchResult.fromNetwork(item))
        }
        return out
    }
}

extension EstateService {
    static var preview: EstateService {
        let out = EstateService()
        out.isPreview = true
        out.exactSearchResult = [SearchResult.fromNetwork(Linkman.NetworkSearchResult.mock)]
        out.fuzzySearchResult = [SearchResult.fromNetwork(Linkman.NetworkSearchResult.mock)]
        out.buildings = (0..<10).map { _ in Building.mock }
        return out
    }
}

extension InquirySheet {
    func toDict() -> [String: Any] {
        var out = [String:Any]()
        return out
    }
}

private extension InquiryType {
    init?(rawValue: Int?) {
        switch rawValue {
        case 1: self = .system
        case 2: self = .manual
        default: return nil
        }
    }
}

private extension InquiryState {
    init?(rawValue: Int?) {
        switch rawValue {
        case 0: self = ._0
        case 1: self = ._1
        case 2: self = ._2
        case 3: self = ._3
        case 4: self = ._4
        case 5: self = ._5
        default: return nil
        }
    }
}

private extension DownloadState {
    init?(rawValue: Int?) {
        switch rawValue {
        case 1: self = ._1
        case 2: self = ._2
        case 3: self = ._3
        case 4: self = ._4
        default: return nil
        }
    }
}
