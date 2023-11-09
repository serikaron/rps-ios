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
}
