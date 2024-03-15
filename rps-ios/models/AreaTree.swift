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
            if Box.isPreview {
                _root = AreaTree.mock
                return _root
            }
            
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
    
    static func children(by codeList: [String]) async -> [AreaTree] {
        let tree = await Self.root
        guard !tree.code.isEmpty else { return [] }

        if codeList.isEmpty {
            return tree.children
        }
        
        let foundNode = codeList.reduce(tree) { treeNode, currCode -> AreaTree? in
            guard let treeNode = treeNode else { return nil }
            return treeNode.children.first { $0.code == currCode }
        }
        
        return foundNode?.children ?? []
    }
}

private extension AreaTree {
    static func from(network: Linkman.NetworkArea) -> AreaTree {
        AreaTree(
            code: network.id, name: network.label,
            children: network.children?.map { AreaTree.from(network: $0) } ?? []
        )
    }
    
//    static var mock: AreaTree {
//        AreaTree(code: "", name: "", children: (0..<10).map { i in
//            let si = "\(i*100)"
//            return AreaTree(code: si, name: si, children: (0..<10).map { j in
//                let sj = "\(i*100 + j*10)"
//                return AreaTree(code: sj, name: sj, children: (0..<10).map { k in
//                    let sk = "\(i*100 + j*10 + k)"
//                    return AreaTree(code: sk, name: sk, children: [])
//                })
//            })
//        })
//    }
}
