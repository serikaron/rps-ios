//
//  AddReportView.swift
//  rps-ios
//
//  Created by serika on 2023/11/21.
//

import SwiftUI

struct AddReportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var accountService: AccountService
    
    @State private var sheet = ReportSheet()
    @State private var areaTree: AreaTree = AreaTree(code: "", name: "", children: [])
    
    let inquiryId: Int?
//    let inquiry: Inquiry?
    let recordId: Int?
    let detail: RoomDetail?
    
    var body: some View {
        ScrollView {
            VStack {
                requireSection
                optionalSection
                commentSection
                fileSection
                buttonSection
            }
        }
        .setupNavigationBar(title: "新建委托") {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            fillSheet()
            Task {
                areaTree = await AreaTree.root
                if sheet.provinceCode != 0 {
                    let pCode = "\(sheet.provinceCode)"
                    sheet.provinceName = areaTree.name(by: [pCode])
                    if sheet.cityCode != 0 {
                        let cCode = "\(sheet.cityCode)"
                        sheet.cityName = areaTree.name(by: [pCode, cCode])
                        if sheet.areaCode != 0 {
                            let aCode = "\(sheet.areaCode)"
                            sheet.areaName = areaTree.name(by: [pCode, cCode, aCode])
                        }
                    }
                }
            }
        }
    }
    
    private var requireSection: some View {
        SectionView(title: "委托基本信息") {
            textItemView(title: "房产证载地址", isRequire: true, binding:  $sheet.certificateAddress)
            Divider()
            dictTypeItemView(title: "物业类型", isRequire: true, allCases: DictType.EstateType.allCases, binding: $sheet.estateType)
            Divider()
            textItemView(title: "委托人", isRequire: true, binding: $sheet.clientName)
            Divider()
            textItemView(title: "联系电话", isRequire: true, binding: $sheet.phone)
            Divider()
            dictTypeItemView(title: "估价目的", isRequire: true, allCases: DictType.ValuationPurpose.allCases, binding: $sheet.purpose)
        }
    }
    
    private var optionalSection: some View {
        SectionView(title: "委托基本信息") {
            itemView(title: "物业地址", isRequire: true) { addressPicker }
            Divider()
            textItemView(title: "详细地址", isRequire: false, binding: $sheet.address)
            Divider()
            textItemView(title: "建筑面积", isRequire: false, binding: $sheet.buildingArea, subFix: "㎡")
            Divider()
            intInputView(title: "建筑年代", isRequire: false, binding: $sheet.buildingYear, subFix: "年")
            Divider()
            dictTypeItemView(title: "建筑结构", isRequire: false, allCases: DictType.BuildingStructure.allCases, binding: $sheet.structure)
            Divider()
            textItemView(title: "土地面积", isRequire: false, binding: $sheet.landArea, subFix: "㎡")
            Divider()
            itemView(title: "所在楼层", isRequire: false) { floorInput }
            Divider()
            dateItemView(title: "估价时点", isRequire: false, binding: $sheet.valuationDate)
            Divider()
            intInputView(title: "单价", isRequire: false, binding: $sheet.price, subFix: "元")
            Divider()
            intInputView(title: "总价", isRequire: false, binding: $sheet.totalPrice, subFix: "万元")
            Divider()
            textItemView(title: "产权人", isRequire: false, binding: $sheet.owner)
            Divider()
            textItemView(title: "产权证号", isRequire: false, binding: $sheet.ownerNumber)
            Divider()
            dictTypeItemView(title: "房屋用途", isRequire: false, allCases: DictType.HousingUse.allCases, binding: $sheet.housingUse)
            Divider()
            dictTypeItemView(title: "建筑朝向", isRequire: false, allCases: DictType.BuildDirection.allCases, binding: $sheet.facing)
            Divider()
            dictTypeItemView(title: "土地用途", isRequire: false, allCases: DictType.LandSe.allCases, binding: $sheet.landSe)
            Divider()
            dictTypeItemView(title: "土地使用权类型", isRequire: false, allCases: DictType.LandUser.allCases, binding: $sheet.landUser)
            Divider()
            dateItemView(title: "土地使用权终止日期", isRequire: false, binding: $sheet.landEndDate)
            Divider()
            textItemView(title: "土地证号", isRequire: false, binding: $sheet.landNumber)
            Divider()
            textItemView(title: "东至", isRequire: false, binding: $sheet.eastTo)
            Divider()
            textItemView(title: "南至", isRequire: false, binding: $sheet.southTo)
            Divider()
            textItemView(title: "西至", isRequire: false, binding: $sheet.westTo)
            Divider()
            textItemView(title: "北至", isRequire: false, binding: $sheet.northTo)
            Divider()
            textItemView(title: "交通条件", isRequire: false, binding: $sheet.traffic)
            Divider()
            textItemView(title: "配套设施", isRequire: false, binding: $sheet.publicFacilities)
            Divider()
            if detail?.hasRoom ?? false {
                dictTypeItemView(title: "装修情况", isRequire: false, allCases: DictType.Decoration.allCases, binding: $sheet.decoration)
            } else {
                dictTypeItemView(title: "装修情况", isRequire: false, allCases: DictType.LevelDecorate.allCases, binding: $sheet.levelDecorate)
            }
            Divider()
            doubleInputView(title: "成新率", isRequire: false, binding: $sheet.buildingNewDegree)
            Divider()
            textItemView(title: "房屋受让人", isRequire: false, binding: $sheet.houseTransferee)
            Divider()
            intInputView(title: "出让金", isRequire: false, binding: $sheet.houseTransferAmount)
            Divider()
            dictTypeItemView(title: "共有情况", isRequire: false, allCases: DictType.CoOwnershipSituation.allCases, binding: $sheet.propertyCoOwnershipSituation)
            Divider()
            textItemView(title: "共有产权人", isRequire: false, binding: $sheet.propertyCoOwnership)
            Divider()
            textItemView(title: "共有产权号", isRequire: false, binding: $sheet.jointOwnershipCertificateNumber)
            Divider()
            dictTypeItemView(title: "空间布局", isRequire: false, allCases: DictType.SpatialLayout.allCases, binding: $sheet.spatialLayout)
            Divider()
            textItemView(title: "使用现状", isRequire: false, binding: $sheet.houseUse)
            Divider()
            textItemView(title: "法定优先偿款", isRequire: false, binding: $sheet.compensation)
            Divider()
            textItemView(title: "贷款人", isRequire: false, binding: $sheet.bkLander)
            Divider()
            textItemView(title: "贷款类型", isRequire: false, binding: $sheet.bkLandType)
            Divider()
//            textItemView(title: "所属单位", isRequire: false, binding: $sheet.organ)
            itemView(title: "所属单位", isRequire: false) {
                Text(sheet.organ)
            }
            Divider()
            textItemView(title: "单位部门", isRequire: false, binding: $sheet.organDept)
            Divider()
            textItemView(title: "单位支行编码", isRequire: false, binding: $sheet.bankBranchCode)
        }
    }
    
    private var commentSection: some View {
        SectionView(title: "备注") {
            TextEditor(text: $sheet.comment)
                .frame(height: 100)
        }
    }
    
    private var fileSection: some View {
        SectionView(title: "电子档案") {
            ImageListView(images: $sheet.images)
        }
    }
    
    private var buttonSection: some View {
        HStack(spacing: 20) {
            Text("提交")
                .customText(size: 16, color: .main)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay (
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.main, lineWidth: 1)
                )
                .onTapGesture {
                    Task {
                        let success = await estateService.addReport(sheet: sheet, state: 1)
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            Text("保存")
                .customText(size: 16, color: .white)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Color.main)
                .cornerRadius(10)
                .onTapGesture {
                    Task {
                        let success = await estateService.addReport(sheet: sheet, state: 0)
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
        .sectionStyle()
    }
    
    private func itemView(title: String, isRequire: Bool, @ViewBuilder _ content: () -> some View) -> some View {
        HStack(spacing: 0) {
            if isRequire {
                Text("*")
                    .customText(size: 14, color: .hex("#FF3030"))
            }
            Text(title).itemTitle()
            Spacer()
            content()
        }
        .frame(height: 36)
    }
    
    private func textItemView(title: String, isRequire: Bool, binding: Binding<String>, subFix: String = "") -> some View {
        itemView(title: title, isRequire: isRequire) {
            HStack {
                TextField("请输入\(title)", text: binding)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
                Text(subFix)
                    .customText(size: 14, color: .text.gray6)
            }
        }
    }
    
    private func dictTypePicker<DT: HasLabel>(name: String, allCases: [DT], binding: Binding<DT?>) -> some View {
        Menu {
            ForEach(Array(zip(allCases.indices, allCases)),
                    id: \.0) { _, type in
                Button {
                    binding.wrappedValue = type
                } label: {
                    Text(type.label)
                }
            }
        } label: {
            Text(binding.wrappedValue == nil ? "请选择\(name)" : binding.wrappedValue?.label ?? "")
                .customText(size: 14,
                            color: binding.wrappedValue == nil ? .text.grayCD : .text.gray3)
            Image.main.arrowIconRight
        }
    }
    
    private func dictTypeItemView<DT: HasLabel>(title: String, isRequire: Bool, allCases: [DT], binding: Binding<DT?>) -> some View {
        itemView(title: title, isRequire: isRequire) {
            dictTypePicker(name: title, allCases: allCases, binding: binding)
        }
    }
    
    private func intInputView(title: String, isRequire: Bool, binding: Binding<Int?>, subFix: String = "") -> some View {
        itemView(title: title, isRequire: isRequire) {
            HStack {
                TextField("请输入\(title)",
                          text: Binding( get: { binding.wrappedValue == nil ? "" : "\(binding.wrappedValue!)" },
                                         set: { binding.wrappedValue = Int($0) })
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .customText(size: 14, color: .text.gray3)
                Text(subFix)
                    .customText(size: 14, color: .text.gray6)
            }
        }
    }
    
    private func doubleInputView(title: String, isRequire: Bool, binding: Binding<Double?>, subFix: String = "") -> some View {
        itemView(title: title, isRequire: isRequire) {
            HStack {
                TextField("请输入\(title)",
                          text: Binding( get: { binding.wrappedValue == nil ? "" : "\(binding.wrappedValue!)" },
                                         set: { binding.wrappedValue = Double($0) })
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .customText(size: 14, color: .text.gray3)
                Text(subFix)
                    .customText(size: 14, color: .text.gray6)
            }
        }
    }
    
    private var addressString: String {
        "\(sheet.provinceName)\(sheet.cityName)\(sheet.areaName)"
    }
    private var addressPicker: some View {
        Menu {
            ForEach(areaTree.children, id: \.code) { province in
                Menu {
                    ForEach(province.children, id: \.code) { city in
                        Menu {
                            ForEach(city.children, id: \.code) { area in
                                Button {
                                    sheet.provinceCode = Int(province.code) ?? 0
                                    sheet.provinceName = province.name
                                    sheet.cityCode = Int(city.code) ?? 0
                                    sheet.cityName = city.name
                                    sheet.areaCode = Int(area.code) ?? 0
                                    sheet.areaName = area.name
                                } label: {
                                    Text(area.name)
                                }
                            }
                        } label: {
                            Text(city.name)
                        }
                    }
                } label: {
                    Text(province.name)
                }
            }
        } label: {
            HStack {
                Text(addressString.isEmpty ? "请选择物业地址" : addressString)
                    .customText(size: 14, color: addressString.isEmpty ? .text.grayCD : .text.gray3)
                Image.main.arrowIconRight
            }
        }
    }
    
    private var floorInput: some View {
        HStack {
            TextField("", text: Binding(
                get: { sheet.beginFloor == nil ? "" : "\(sheet.beginFloor!)" },
                set: { sheet.beginFloor = Int($0) }
            ))
            .frame(width: 36)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.text.grayCD, lineWidth: 1)
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            Text("-")
            TextField("", text: Binding(
                get: { sheet.endFloor == nil ? "" : "\(sheet.endFloor!)" },
                set: { sheet.endFloor = Int($0) }
            ))
            .frame(width: 36)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.text.grayCD, lineWidth: 1)
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            Text("层")
        }
        .itemContent()
    }
    
    private func dateItemView(title: String, isRequire: Bool, binding: Binding<String>) -> some View {
        itemView(title: title, isRequire: isRequire) {
            HStack {
                Text(binding.wrappedValue.isEmpty ? "请选择\(title)" : binding.wrappedValue)
                    .customText(size: 14,
                                color: binding.wrappedValue.isEmpty ? .text.grayCD : .text.gray3)
                Image.main.arrowIconRight
            }
            .overlay(
                DatePicker("",
                           selection: Binding(
                            get: { binding.wrappedValue.toDate() ?? Date() },
                            set: { binding.wrappedValue = $0.toString() }),
                           displayedComponents: [.date]
                          )
                .blendMode(.destinationOver)
            )
        }
    }
    
    private func fillSheet() {
        Task {
            print("debug inquiryId:\(inquiryId) recordId:\(recordId)")
            sheet = await estateService.getReportSheet(inquiryId: inquiryId, recordId: recordId)
        }
    }
    
//    private func fillSheet1() {
//        guard let inquiry = inquiry,
//              let detail = detail
//        else { return }
//        
//        sheet.address = detail.roomName
//        sheet.certificateAddress = inquiry.address ?? ""
//        sheet.estateType = detail.estateType
//        sheet.clientName = accountService.account?.nickname ?? ""
//        sheet.buildingArea = inquiry.buildingArea == nil ? "" : "\(inquiry.buildingArea!)"
//        sheet.phone = accountService.account?.phone ?? ""
//        sheet.buildingYear = Int(inquiry.buildingYear ?? "0")
//        sheet.structure = inquiry.structure
//        
//        if let floor = inquiry.floor {
//            let l = floor.components(separatedBy: "-")
//            if l.count == 2 {
//                sheet.beginFloor = Int(l[0])
//                sheet.endFloor = Int(l[1])
//            }
//        }
//        
//        if let price = Double(inquiry.price) {
//            sheet.price = Int((price / 10000) + 0.5)
//        }
//        if let totalPrice = Double(inquiry.totalPrice) {
//            sheet.totalPrice = Int((totalPrice / 10000) + 0.5)
//        }
//        
//        sheet.valuationDate = inquiry.date
//        sheet.housingUse = inquiry.housingUse
//        sheet.facing = DictType.BuildDirection(rawValue: inquiry.facing)
//        sheet.landSe = inquiry.landSe
//        sheet.northTo = detail.compoundToNorth
//        sheet.westTo = detail.compoundToWest
//        sheet.southTo = detail.compoundToSouth
//        sheet.eastTo = detail.compoundToEast
//        sheet.traffic = [detail.compoundBusLine, detail.compoundFastBus, detail.compoundSubway].joined(separator: ",")
//        sheet.publicFacilities = [
//            detail.compoundVegeMarket, detail.compoundBusinessSet,
//            detail.compoundHospital, detail.compoundFinaceOrg,
//            detail.compoundFinaceOrg, detail.compoundStadium,
//            detail.compoundRelaxSquare, detail.compoundKindergarten,
//            detail.compoundPrimarySchool, detail.compoundMiddleSchool
//        ].joined(separator: ",")
//        if detail.hasRoom {
//            sheet.decoration = DictType.Decoration(rawValue: detail.decoration)
//        } else {
//            sheet.levelDecorate = detail.buildingLevelDecorate
//        }
//        
//        sheet.organ = accountService.account?.placeUnit ?? ""
//        sheet.organDept = accountService.account?.placeOrganization ?? ""
//        
//        sheet.provinceCode = detail.provinceCode
//        print(detail.provinceCode)
//        print(sheet.provinceCode)
//        sheet.cityCode = detail.cityCode
//        sheet.areaCode = detail.areaCode
//        if sheet.provinceCode != 0 {
//            let pCode = "\(sheet.provinceCode)"
//            sheet.provinceName = areaTree.name(by: [pCode])
//            if sheet.cityCode != 0 {
//                let cCode = "\(sheet.cityCode)"
//                sheet.cityName = areaTree.name(by: [pCode, cCode])
//                if sheet.areaCode != 0 {
//                    let aCode = "\(sheet.areaCode)"
//                    sheet.areaName = areaTree.name(by: [pCode, cCode, aCode])
//                }
//            }
//        }
//    }
}

#Preview {
    AddReportView(inquiryId: nil, recordId: nil, detail: nil)
        .environmentObject(EstateService.preview)
        .environmentObject(AccountService())
}
