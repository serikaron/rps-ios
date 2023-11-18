//
//  Banner.swift
//  rps-ios
//
//  Created by serika on 2023/11/18.
//

import Foundation

struct Banner: Codable {
    let ossUrl: String
    
    static var list: [Banner] {
        get async {
            do {
                let r = try await Linkman.shared.getBanners()
                return r.filter { $0.fvOssUrl != nil }
                    .map { Banner(ossUrl: $0.fvOssUrl!) }
            } catch {
                print("get banners FAILED: \(error)")
                return []
            }
        }
    }
}
