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
            return await .fromNetwork(rsp)
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
            let l = await SearchResultList.fromNetwork(rsp.records)
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
    
    var previewFloors = Floors.mock(floorCount: 10, unitCount: 4)
    func getFloors(buildingId: Int, estateType: String, areaCode: Int) async -> Floors {
        print("getFloors - 1")
        if (isPreview) { return previewFloors }
        
        print("getFloors - 2")
        
        do {
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
                        return Room(floorNum: r.fiFloorNum ?? 0, roomNum: r.fvRoomNum ?? "", roomName: r.fvRoomName ?? "")
                    }
                )
            }
            return Floors(unitTitles: units.compactMap { $0.type }, floors: floors)
        } catch {
            print("getFloors FAILED: \(error)")
            return Floors.empty
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
                     comId: 1
        )
    }
    
    static func fromNetwork(_ item: Linkman.NetworkSearchResult) async -> SearchResult {
        var estateType = ""
        if let fvEstateType = item.fvEstateType {
            estateType = await DictType.estateType(of: fvEstateType) ?? ""
        }
        return SearchResult(
            id: item.id,
            roomName: item.fvFamilyRoomName,
            compoundName: item.fvCompoundName,
            completionDate: item.fvCompletionDate,
            estateType: item.fvEstateType,
            estateTypeLabel: estateType,
            compoundNameAlias: item.fvNameAlias,
            address: item.fvStreetMark,
            picUrls: item.picUrls,
            comId: item.fiCompoundId
        )
    }
}

extension SearchResultList {
    static func fromNetwork(_ networkList: [Linkman.NetworkSearchResult]) async -> SearchResultList {
        var out: SearchResultList = []
        for item in networkList {
            out.append(await SearchResult.fromNetwork(item))
        }
        return out
    }
}

extension EstateService {
    static var preview: EstateService {
        let out = EstateService()
        out.isPreview = true
        Task {
            out.exactSearchResult = [await SearchResult.fromNetwork(Linkman.NetworkSearchResult.mock)]
            out.fuzzySearchResult = [await SearchResult.fromNetwork(Linkman.NetworkSearchResult.mock)]
            out.buildings = (0..<10).map { _ in Building.mock }
        }
        return out
    }
}
