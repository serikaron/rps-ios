//
//  AreaTree.swift
//  rps-ios
//
//  Created by serika on 2023/11/20.
//

import Foundation


struct AreaTree {
    let code: String
    let name: String
    let children: [AreaTree]
    
    static private var _root = AreaTree(code: "", name: "", children: [])
    
    static var root: AreaTree {
        get async {
            if _root.code.isEmpty {
                do {
                    let rsp = try await Linkman.shared.getAreaTree()
                    guard !rsp.isEmpty else { throw "area tree is empty"}
                    _root = .from(network: rsp[0])
                } catch {
                    print("getAreaTree FAILED!!! \(error)")
                }
            }
            
            return _root
        }
    }
}

private extension AreaTree {
    static func from(network: Linkman.NetworkArea) -> AreaTree {
        AreaTree(
            code: network.id, name: network.label,
            children: network.children?.map { AreaTree.from(network: $0) } ?? []
        )
    }
}
