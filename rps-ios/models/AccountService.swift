//
//  User.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation
import Combine

struct Account {
    let id: Int
    let orgId: Int
    let unitId: Int
    let nickname: String
    let phone: String
    let placeOrganization: String
    let placeUnit: String
}

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
        let rsp = try await Linkman.shared.getInfo()
        account = Account(
            id: rsp.user.id,
            orgId: rsp.user.fiOrgId,
            unitId: rsp.user.fiUnitId,
            nickname: rsp.user.fvClientNickName,
            phone: rsp.user.fiCellphone,
            placeOrganization: rsp.user.fvPlaceOrganization,
            placeUnit: rsp.user.fvPlaceUnit
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
}


