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
        if Box.isPreview { return .mock }
        
        guard unitId != 0, !startTime.isEmpty, !endTime.isEmpty, !estateType.isEmpty else {
            return .empty
        }
        
        do {
            let districtRsp = try await Linkman.shared.getAuthAreaList(unitId: unitId)
            let districtId = districtRsp.compactMap { $0.fiAreaCode }
            let curveRsp = try await Linkman.shared.getCurve(startTime: startTime, endTime: endTime, estateType: estateType, districtId: districtId)
            guard !curveRsp.isEmpty else { return .empty }
            let curveData = curveRsp[0]
            return Curve(
                name: curveData.code,
                values: curveData.value.verticalShaft,
                xAxisLabels: curveData.value.horizontalAxis.map { $0.subfixDate }
            )
        } catch {
            print("get districtCurve FAILED!!! \(error)")
            return .empty
        }
    }
    
    static func combinedCurve(unitId: Int, startTime: String, endTime: String, estateType: String) async -> Curve {
        if Box.isPreview { return .mock }
        
        guard unitId != 0, !startTime.isEmpty, !endTime.isEmpty, !estateType.isEmpty else { return .empty }
        
        do {
            let districtRsp = try await Linkman.shared.getAuthAreaList(unitId: unitId)
            let districtId = districtRsp.compactMap { $0.fiAreaCode }
            let curveRsp = try await Linkman.shared.getCombinedCurve(startTime: startTime, endTime: endTime, estateType: estateType, districtId: districtId)
            return Curve(
                name: "多区合并价格",
                values: curveRsp.verticalShaft.map { Double($0) },
                xAxisLabels: curveRsp.horizontalAxis.map { $0.subfixDate }
            )
        } catch {
            print("get combinedCurve FAILED!!! \(error)")
            return .empty
        }
    }
    
    static func compoundCurve(unitId: Int, compoundId: Int, startTime: String, endTime: String, estateType: String) async -> Curve {
        if Box.isPreview { return .mock }
        
        guard unitId != 0, compoundId != 0, !startTime.isEmpty, !endTime.isEmpty, !estateType.isEmpty else { return .empty }
        
        do {
            let districtRsp = try await Linkman.shared.getAuthAreaList(unitId: unitId)
            let districtIds = districtRsp.compactMap { $0.fiAreaCode }
            guard let districtId = districtIds.first else { return .empty }
            let rsp = try await Linkman.shared.getCompoundCurve(compoundId: compoundId, startTime: startTime, endTime: endTime, estateType: estateType, districtId: districtId)
            return Curve(
                name: "",
                values: rsp.map { $0.price ?? 0 },
                xAxisLabels: rsp.map { $0.evaluateTime ?? "" }.map { $0.subfixDate }
            )
        } catch {
            print("compoundCurve FAILED!!! \(error)")
            return .empty
        }
    }
    
    static func baseDistrictCurve(compoundId: Int, startTime: String, endTime: String, estateType: String) async -> Curve {
        if Box.isPreview { return .mock }
        do {
            let rsp = try await Linkman.shared.getBaseDistrictCurve(compoundId: compoundId, startTime: startTime, endTime: endTime, estateType: estateType)
            return Curve(
                name: "",
                values: rsp.map { $0.price ?? 0 },
                xAxisLabels: rsp.map { $0.evaluateTime ?? "" }.map { $0.subfixDate }
            )
        } catch {
            print("compoundCurve FAILED!!! \(error)")
            return .empty
        }
    }
}

extension Curve {
    static var empty: Curve {
        Curve(name: "", values: [], xAxisLabels: [])
    }
}

private extension String {
    var subfixDate: String {
        String(self.suffix(from: self.index(self.startIndex, offsetBy: 2)))
    }
}

extension [String] {
    var dateFormatted: [String] {
        var year: String?
        
        var out = [String]()
        for date in self {
            let v = date.components(separatedBy: "-")
            
            guard v.count == 2 else {
                out.append(date)
                continue
            }
            
            let y = v[0]
            let m = v[1]
            if year == y {
                out.append(m)
            } else {
                out.append(date.subfixDate)
                year = y
            }
        }
        
        return out
    }
}
