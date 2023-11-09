//
//  Notice.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

struct Notice {
    let title: String
    
    static func list(pageNum: Int, pageSize: Int, orgId: Int) async -> [Notice] {
        do {
            let rsp = try await Linkman.shared.getNotices(pageNum: pageNum, pageSize: pageSize, orgId: orgId)
            return rsp.records.map { record in
                Notice(title: record.noticeTitle)
            }
        } catch {
            return []
        }
    }
}
