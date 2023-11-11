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
    let compoundNameAlias: String?
    let address: String?
    let picUrls: String?
}
typealias SearchResultList = [SearchResult]

@MainActor
class EstateService: ObservableObject {
    private var fuzzySearchTask: Task<Void, Never>?
    @Published var fuzzySearchResult: SearchResultList = []
    
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
            return await rsp.asyncMap { await SearchResult.fromNetwork($0) }
        } catch {
            return []
        }
    }
    
    @Published var exactSearchResult: SearchResultList = []
    
    func exactSearch(keyword: String) async {
        guard !keyword.isEmpty else { return }
        
        do {
            let rsp = try await Linkman.shared.exactSearch(keyword: keyword)
            let l = await rsp.records.asyncMap { await SearchResult.fromNetwork($0) }
        } catch {
            print("excatSearch ERROR: \(error)")
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
                     compoundNameAlias: "compoundNameAlias-\(num)",
                     address: "address-\(num)",
                     picUrls: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg"
        )
    }
    
    static func fromNetwork(_ item: Linkman.NetworkSearchResult) async -> SearchResult {
        let estateType = await DictType.estateType(of: item.fvEstateType ?? "") ?? ""
        return SearchResult(
            id: item.id,
            roomName: item.fvFamilyRoomName,
            compoundName: item.fvCompoundName,
            completionDate: item.fvCompletionDate,
            estateType: estateType,
            compoundNameAlias: item.fvNameAlias,
            address: item.fvStreetMark,
            picUrls: item.picUrls
        )
    }
}

extension EstateService {
    static var preview: EstateService {
        let out = EstateService()
        Task {
            out.exactSearchResult = [await SearchResult.fromNetwork(Linkman.NetworkSearchResult.mock)]
            out.fuzzySearchResult = [await SearchResult.fromNetwork(Linkman.NetworkSearchResult.mock)]
        }
        return out
    }
}
