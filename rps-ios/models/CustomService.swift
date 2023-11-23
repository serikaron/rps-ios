//
//  CustomService.swift
//  rps-ios
//
//  Created by serika on 2023/11/22.
//

import Foundation


struct CSUser {
    let name: String
    let link: String?
}

struct CSDept {
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    let id: Int
    let name: String
    private(set) var users: [CSUser] = []
    
    var expanded = false
    
    private var _loaded = false
    
    mutating func load() async {
        if Box.isPreview {
            users = CSUser.mock
            return
        }
        
        guard !_loaded else { return }
        
        do {
            let rsp = try await Linkman.shared.getCSUsers(nodeId: id, pageSize: 10, pageNum: 1)
            users = rsp.rows
                .filter { $0.fvServiceLink != nil }
                .map { CSUser(name: $0.nickName, link: $0.fvServiceLink) }
            _loaded = true
        } catch {
            print("CSDept.load FAILED!!! \(error)")
        }
    }
}

struct CSComp {
    let name: String
    var depts: [CSDept]
    
    var expanded = true
    
    static var list: [CSComp] {
        get async {
            if Box.isPreview { return CSComp.mock }
            
            do {
                let rsp = try await Linkman.shared.getCSTree()
                return rsp.map { CSComp.from(network: $0) }
            } catch {
                print("CSComp.list FAILED!!! \(error)")
                return []
            }
        }
    }
}

private extension CSDept {
    static func from(network: Linkman.NetworkCSNode) -> Self {
        CSDept(id: network.id, name: network.label)
    }
}

private extension CSComp {
    static func from(network: Linkman.NetworkCSNode) -> Self {
        CSComp(
            name: network.label,
            depts: network.children == nil ? [] :
                network.children!.map { CSDept.from(network: $0) }
        )
    }
}
