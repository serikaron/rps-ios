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
    
    @Published var roomDetail: RoomDetail = .empty
    func getRoomDetail(estateType: String, areaCode: Int, familyRoomName: String, buildingId: Int, orgId: Int) async {
//        print("getRoomDetail, estateType:\(estateType), areaCode:\(areaCode), familyRoomName:\(familyRoomName), buildingId:\(buildingId)")
        roomDetail = .empty
        do {
            let roomCount = try await Linkman.shared.getRoomCount(estateType: estateType, buildingId: buildingId)
            let rsp = try await Linkman.shared.getRoomDetail(estateType: estateType, areaCode: areaCode, familyRoomName: familyRoomName, orgId: orgId)
            roomDetail = RoomDetail(networkRoomDetail: rsp, roomCount: roomCount)
        } catch {
            print("getRoomDetail FAILED: \(error)")
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
