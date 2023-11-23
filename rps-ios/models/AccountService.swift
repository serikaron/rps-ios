//
//  User.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation
import Combine

@MainActor
class AccountService: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var account: Account? {
        didSet {
            UserDefaults.account = account
        }
    }
    
    var cancelable: Cancellable?
    
    init() {
        Box.shared.tokenSubject
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .assign(to: &$isLoggedIn)
        
        cancelable = Box.shared.tokenSubject
            .dropFirst()
            .sink(receiveValue: { token in
                UserDefaults.token = token
            })
        
        account = UserDefaults.account
    }
    
    func login(username: String, password: String) async {
        do {
            let loginRsp = try await Linkman.shared.login(phone: username, password: password)
            Box.setToken(loginRsp.access_token)
            try await getInfo()
        } catch {
            print("login failed: \(error)")
            account = nil
            Box.setToken(nil)
        }
    }
    
    private func getInfo() async throws {
        if Box.isPreview { return }
        
        let rsp = try await Linkman.shared.getInfo()
        account = Account(
            id: rsp.user.id,
            orgId: rsp.user.fiOrgId,
            unitId: rsp.user.fiUnitId,
            nickname: rsp.user.fvClientNickName,
            phone: "\(rsp.user.fiCellphone)",
            placeOrganization: rsp.user.fvPlaceOrganization,
            placeUnit: rsp.user.fvPlaceUnit,
            clientName: rsp.user.fvClientName,
            position: rsp.user.fvPosition ?? "",
            status: DictType.CommonStatus(rawValue: rsp.user.fvApStatus) ?? ._0,
            date: rsp.user.fvValidDate,
            gender: Gender(rawValue: rsp.user.fvClientGender) ?? .male,
            birthday: rsp.user.fdDateBirth ?? "",
            email: rsp.user.fvEmail ?? "",
            workPhone: rsp.user.fiWorkPhone == nil ? "" : "\(rsp.user.fiWorkPhone!)"
        )
    }
    
    func register(account: String, name: String, gender: Gender, birthday: String,
                  company: String, department: String, position: String,
                  phone: String, mobile: String, email: String, contact: String,
                  address: String
    ) async {
        do {
            try await Linkman.shared.register(account: account, name: name, gender: gender,
                                        birthday: birthday, company: company, department: department, position: position,
                                        phone: phone, mobile: mobile, email: email, contact: contact, address: address)
        } catch {
            
        }
    }
    
    func getNotice(pageNum: Int, pageSize: Int, orgId: Int) async {
    }
    
    func getMessage(pageNum: Int, pageSize: Int) async -> (total: Int, current: Int, list: [Message]) {
        if Box.isPreview {
            return (100, pageNum, Message.mock)
        }
        
        do {
            let rsp = try await Linkman.shared.getMessages(pageSize: pageSize, pageNum: pageNum)
            return (rsp.total, rsp.current,
                    rsp.records.map { Message(id: $0.id ?? 0,
                                              content: $0.fvTextMessageContent ?? "",
                                              read: $0.fiState == 1,
                                              date: $0.fdCreateTime ?? "",
                                              sender: $0.fvCreateBy ?? "") }
            )
        } catch {
            print("getMessage FAILED!!! \(error)")
            return (0, 0, [])
        }
    }
    
    func readMessage(id: Int) async {
        do {
            try await Linkman.shared.readMessage(id: id)
        } catch {
            print("readMessage FAILED!!! \(error)")
        }
    }
    
    func getUnread() async -> Int {
        do {
            return try await Linkman.shared.getUnread()
        } catch {
            print("getUnread FAILED!!! \(error)")
            return 0
        }
    }
    
    func logout() async {
        do {
            try await Linkman.shared.logout()
            Box.setToken(nil)
        } catch {
            print("logout FAILED!!! \(error)")
        }
    }
    
    func resetPassword(orgPassword: String, newPassword: String, newPassword2: String) async {
        guard !orgPassword.isEmpty, !newPassword.isEmpty, !newPassword2.isEmpty else {
            Box.sendError("请输入密码")
            return
        }
        
        guard newPassword == newPassword2 else {
            Box.sendError("两次输入密码不一样")
            return
        }
        
        do {
            try await Linkman.shared.updatePwd(oldPassword: orgPassword, newPassword: newPassword)
        } catch {
            print("resetPassword FAILED!!! \(error)")
        }
    }
    
    func updateInfo(gender: Gender, phone: String, birthday: String, email: String, workPhone: String) async {
        do {
            try await Linkman.shared.editClientUser(gender: gender.dictKey, phone: phone, birthday: birthday, email: email, workPhone: workPhone)
            if let account = account {
                self.account = Account(
                    id: account.id,
                    orgId: account.orgId,
                    unitId: account.unitId,
                    nickname: account.nickname,
                    phone: phone,
                    placeOrganization: account.placeOrganization,
                    placeUnit: account.placeUnit,
                    clientName: account.clientName,
                    position: account.position,
                    status: account.status,
                    date: account.date,
                    gender: gender,
                    birthday: birthday,
                    email: email,
                    workPhone: workPhone)
            } else {
                try await getInfo()
            }
        } catch {
            print("updateInfo FAILED!!! \(error)")
        }
    }
}

extension AccountService {
    static var preview: AccountService {
        Box.isPreview = true
        let out = AccountService()
        out.account = Account(
            id: 0, orgId: 294, unitId: 0, nickname: "张三", phone: "13333333333", placeOrganization: "", placeUnit: "",
            clientName: "hqb", position: "专员", status: ._0, date: "2024-11-30", gender: .male, birthday: "", email: "123456@qq.com", workPhone: "13344444444"
        )
        return out
    }
}


