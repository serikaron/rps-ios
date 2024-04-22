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
    
    func name(by codeList: [String]) -> String {
        let foundNode = codeList.reduce(self) { treeNode, currCode -> AreaTree? in
            guard let treeNode = treeNode else { return nil }
            return treeNode.children.first { $0.code == currCode }
        }
        
        return foundNode?.name ?? ""
    }
    
    func children(by codeList: [String]) -> [AreaTree] {
        if codeList.isEmpty {
            return self.children
        }
        
        let foundNode = codeList.reduce(self) { treeNode, currCode -> AreaTree? in
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
}

//MARK: - UserAreaTree

struct UserAreaTree {
    private(set) var tree: AreaTree?
    private(set) var provinceCode: Int?
    private(set) var cityCode: Int?
    
    func name(by codeList: [String]) -> String {
        tree?.name(by: codeList) ?? ""
    }
}


@MainActor
class AreaTreeService: ObservableObject {
    @Published private(set) var areaTree: AreaTree?
    @Published private(set) var userAreaTree: UserAreaTree?
    
    func loadAreaTree() async {
        if Box.isPreview {
            areaTree = AreaTree.mock
            return
        }
        
        do {
            let rsp = try await Linkman.shared.getAreaTree()
            guard !rsp.isEmpty else { throw "area tree is empty"}
            areaTree = .from(network: rsp[0])
        } catch {
            print("getAreaTree FAILED!!! \(error)")
            Box.sendError("加载省市区失败")
        }
    }
    
    private var _unitId: Int?
    func loadUserAreaTree(with unitId: Int) async {
        if Box.isPreview {
            userAreaTree = UserAreaTree(tree: .mock, provinceCode: 0, cityCode: 0)
            return
        }
        
        
        if unitId == _unitId && userAreaTree != nil {
            return
        }
        
        _unitId = unitId
        
        do {
            let rsp = try await Linkman.shared.getUserAreaTree(unitId: unitId)
            guard let has = rsp.treeList?.isEmpty, has else { throw "area tree is empty"}
            userAreaTree = UserAreaTree(
                tree: .from(network: rsp.treeList![0]),
                provinceCode: rsp.defaultParentCode,
                cityCode: rsp.defaultCode)
        } catch {
            print("getAreaTree FAILED!!! \(error)")
            Box.sendError("加载用户省市区失败")
        }
    }
    
    func setProvince(code: Int) {
        userAreaTree?.setProvince(code: code)
    }
    
    func setCity(code: Int) {
        userAreaTree?.setCity(code: code)
    }
}

private extension UserAreaTree {
    mutating func setProvince(code: Int) {
        provinceCode = code
    }
    
    mutating func setCity(code: Int) {
        cityCode = code
    }
}
