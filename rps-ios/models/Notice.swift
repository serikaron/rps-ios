//
//  Notice.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

struct Notice {
    let title: String
    let date: String
    let content: String
    
    static func list(pageNum: Int, pageSize: Int, orgId: Int) async -> ([Notice], Int, Int) {
        if Box.isPreview {
            return (Notice.mock, 100, pageNum)
        }
        
        do {
            let rsp = try await Linkman.shared.getNotices(pageNum: pageNum, pageSize: pageSize, orgId: orgId)
            return (rsp.records.map { record in
                Notice(
                    title: record.noticeTitle ?? "",
                    date: record.fdReleaseTime ?? "",
                    content: record.noticeContent ?? ""
                )
            }, rsp.total, rsp.current)
        } catch {
            print("Notice.list FAILED!!! \(error)")
            return ([], 0, 0)
        }
    }
}

