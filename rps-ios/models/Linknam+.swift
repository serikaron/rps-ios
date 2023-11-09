//
//  Linknam+.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

extension Linkman {
    struct LoginResponse: Codable {
        let access_token: String
    }
    
    func login(phone: String, password: String) async throws -> LoginResponse {
        return try await Request()
            .with(\.path, setTo: "/auth/rps/clientLogin")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["username": phone, "password": password, "deviceType": "APP"])
            .with(\.standaloneResponse, setTo: standaloneResponse(LoginResponse(access_token: "mockToken")))
            .make()
            .response() as LoginResponse
    }
    
    struct NetworkUser: Codable {
        let id: Int
        let fiOrgId: Int
    }
    
    struct GetInfoResponse: Codable {
        let user: NetworkUser
    }
    
    func getInfo() async throws -> GetInfoResponse {
        return try await Request()
            .with(\.path, setTo: "/account/rps/account/clientUser/getInfo")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse(GetInfoResponse.mock))
            .make()
            .response() as GetInfoResponse
    }
    
    func register(account: String, name: String, gender: Gender, birthday: String,
                  company: String, department: String, position: String,
                  phone: String, mobile: String, email: String, contact: String,
                  address: String
    ) async throws {
        try await Request()
            .with(\.path, setTo: "/account/rps/account/clientUser/applyLoginClientUser")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: [
                "fvClientName": account,
                "fvClientNickName": name,
                "fvClientGender": gender.text,
                "fdDateBirth": birthday,
                "fvPlaceUnit": company,
                "fvPlaceOrganization": department,
                "fvPosition": position,
                "fiWorkPhone": phone,
                "fiCellphone": mobile,
                "fvEmail": email,
                "fvQqMsn": contact,
                "fvPlaceArea": address
            ])
            .make()
    }
    
    struct NoticeRecord: Codable {
        let noticeTitle: String
    }
    
    struct NoticeResponse: Codable {
        let records: [NoticeRecord]
    }
    
    func getNotices(pageNum: Int, pageSize: Int, orgId: Int) async throws -> NoticeResponse {
        return try await Request()
            .with(\.path, setTo: "/system/rps/rpsNotice/page")
            .with(\.method, setTo: .GET)
            .with(\.query, setTo: [
                "pageNum": "\(pageNum)", "pageSize": "\(pageSize)", "orgId": "\(orgId)",
                "type": "3", "fvPushstatus": "已发布", "fiTypeOfNotice": "0,2,3"
            ])
            .with(\.standaloneResponse, setTo: standaloneResponse(NoticeResponse(records: [NoticeRecord.mock])))
            .make()
            .response() as NoticeResponse
    }
}

private extension Linkman.GetInfoResponse {
    static var mock: Linkman.GetInfoResponse {
        return Linkman.GetInfoResponse(user: Linkman.NetworkUser(
            id: 0,
            fiOrgId: 0
        ))
    }
}

private extension Linkman.NoticeRecord {
    static var mock: Linkman.NoticeRecord {
        return Linkman.NoticeRecord(noticeTitle: "公告1")
    }
}

