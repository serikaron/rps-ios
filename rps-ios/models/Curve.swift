//
//  Curve.swift
//  rps-ios
//
//  Created by serika on 2023/11/19.
//

import Foundation

struct Curve {
    let name: String
    let values: [Double]
    let xAxisLabels: [String]
    
    static func getCurve() async -> Curve {
        return Curve.mock
    }
    
    static func districtCurve(unitId: Int, startTime: String, endTime: String, estateType: String) async -> Curve {
        do {
            let districtRsp = try await Linkman.shared.getAuthAreaList(unitId: unitId)
            let districtId = districtRsp.compactMap { $0.fiAreaCode }
            let curveRsp = try await Linkman.shared.getCurve(startTime: startTime, endTime: endTime, estateType: estateType, districtId: districtId)
            guard !curveRsp.isEmpty else { return .empty }
            let curveData = curveRsp[0]
            return Curve(
                name: curveData.code,
                values: curveData.value.verticalShaft,
                xAxisLabels: curveData.value.horizontalAxis)
        } catch {
            print("get districtCurve FAILED!!! \(error)")
            return .empty
        }
    }
    
    static func combinedCurve(unitId: Int, startTime: String, endTime: String, estateType: String) async -> Curve {
        do {
            let districtRsp = try await Linkman.shared.getAuthAreaList(unitId: unitId)
            let districtId = districtRsp.compactMap { $0.fiAreaCode }
            let curveRsp = try await Linkman.shared.getCombinedCurve(startTime: startTime, endTime: endTime, estateType: estateType, districtId: districtId)
            return Curve(
                name: "多区合并价格",
                values: curveRsp.verticalShaft.map { Double($0) ?? 0 },
                xAxisLabels: curveRsp.horizontalAxis)
        } catch {
            print("get combinedCurve FAILED!!! \(error)")
            return .empty
        }
    }
}

extension Curve {
    static var empty: Curve {
        Curve(name: "", values: [], xAxisLabels: [])
    }
}
