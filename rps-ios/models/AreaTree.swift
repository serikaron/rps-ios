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
    
    func name(by codeList: [String]) -> String {
        guard !Self._root.code.isEmpty else { return "" }
        
        let foundNode = codeList.reduce(Self._root) { treeNode, currCode -> AreaTree? in
            guard let treeNode = treeNode else { return nil }
            return treeNode.children.first { $0.code == currCode }
        }
        
        return foundNode?.name ?? ""
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
