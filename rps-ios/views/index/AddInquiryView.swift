//
//  AddInquiryView.swift
//  rps-ios
//
//  Created by serika on 2023/11/20.
//

import SwiftUI

struct AddInquiryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService

    let inquiryId: Int?
    let roomDetail: RoomDetail?
    let inquiry: Inquiry?
    let record: Record?
    
    @State private var sheet: InquirySheet = .empty
    @State private var areaTree = AreaTree(code: "", name: "", children: [])
    
    private var landArea: Binding<String> {Binding(
        get: {
            if let area = sheet.landArea {
                return "\(area)"
            } else {
                return ""
            }
        },
        set: { sheet.landArea = Double($0) }
    )}
    private var buildingArea: Binding<String> {Binding(
        get: { 
            if let area = sheet.buildingArea {
                return "\(area)"
            } else {
                return ""
            }
        },
        set: { sheet.buildingArea = Double($0) }
    )}
    private var valuationDate: Binding<Date> {Binding(
        get: { sheet.valuationDate.toDate() ?? Date() },
        set: { sheet.valuationDate = $0.toString() }
    )}
    private var upperFloor: Binding<String> {Binding(
        get: {
            guard let a = sheet.upperFloor else { return "" }
            return "\(a)"
        },
        set: { sheet.upperFloor = Int($0) }
    )}
    private var underFloor: Binding<String> {Binding(
        get: {
            guard let a = sheet.underFloor else { return "" }
            return "\(a)"
        },
        set: { sheet.underFloor = Int($0) }
    )}
    private var beginFloor: Binding<String> {Binding(
        get: {
            guard let a = sheet.beginFloor else { return "" }
            return "\(a)"
        },
        set: { sheet.beginFloor = Int($0) }
    )}
    private var endFloor: Binding<String> {Binding(
        get: {
            guard let a = sheet.endFloor else { return "" }
            return "\(a)"
        },
        set: { sheet.endFloor = Int($0) }
    )}

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                requireSection
                optionalSection
                descriptionSection
                commentSection
                fileSection
                buttonSection
            }
        }
        .padding(.vertical, 10)
        .background(Color.view.background)
        .setupNavigationBar(title: "人工询价") {
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
    
    private func fillSheet() {
        guard let inquiryId = inquiryId,
              inquiryId != 0
        else { return }
        
        Task {
            let inquiry = await estateService.inquiry(by: inquiryId)
            fillSheet(with: inquiry)
        }
    }
    
    private func fillSheet1() {
        if let roomDetail = roomDetail {
            sheet.provinceCode = roomDetail.provinceCode
            sheet.cityCode = roomDetail.cityCode
            sheet.areaCode = roomDetail.areaCode
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
            sheet.upperFloor = Int(roomDetail.height)
            if let floor = roomDetail.floor {
                let l = floor.components(separatedBy: "-")
                if l.count == 2 {
                    sheet.beginFloor = Int(l[0])
                    sheet.endFloor = Int(l[1])
                }
            }
        }
        if let inquiry = inquiry {
            fillSheet(with: inquiry)
        }
        if let record = record {
            sheet.address = record.address
            sheet.estateType = record.estateType
//            sheet.buildingArea = record.area
            sheet.contact = record.contact
            sheet.phone = record.contactPhone
            sheet.buildingYear = record.buildingYear
            sheet.structure = record.structure
            sheet.valuationDate = record.valuationDate
            let l = record.floor.components(separatedBy: "-")
            if l.count == 2 {
                sheet.beginFloor = Int(l[0])
                sheet.endFloor = Int(l[1])
            }
            if sheet.provinceCode == 0 {
                sheet.provinceCode = record.provinceCode
                sheet.cityCode = record.cityCode
                sheet.areaCode = record.areaCode
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
    
    private func fillSheet(with inquiry: Inquiry) {
        sheet.address = inquiry.address ?? ""
        sheet.estateType = inquiry.estateType
        sheet.buildingArea = inquiry.buildingArea
        sheet.contact = inquiry.contact ?? ""
        sheet.phone = inquiry.phone ?? ""
        sheet.buildingYear = inquiry.buildingYear ?? ""
//                sheet.structure = inquiry.structure
        sheet.beginFloor = inquiry.beginFloor
        sheet.endFloor = inquiry.endFloor
        sheet.valuationDate = inquiry.valuationDate ?? ""
        sheet.structure = inquiry.structure
        sheet.purpose = inquiry.purpose
        sheet.landArea = inquiry.area
        sheet.upperFloor = inquiry.upperFloor
        sheet.underFloor = inquiry.lowerFloor
        sheet.telephone = inquiry.telephone ?? ""
        sheet.custodian = inquiry.custodian ?? ""
        
        if sheet.provinceCode == 0 {
            sheet.provinceCode = inquiry.provinceCode ?? 0
            sheet.cityCode = inquiry.cityCode ?? 0
            sheet.areaCode = inquiry.areaCode ?? 0
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
        }    }
    
    private var requireSection: some View {
        SectionView(title: "询价基本信息") {
            itemView(title: "物业地址", isRequire: true) { addressPicker }
            Divider()
            itemView(title: "详细地址", isRequire: true) {
                TextField("请输入产权地址", text: $sheet.address)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
            }
            Divider()
            itemView(title: "物业类型", isRequire: true) { estateTypePicker }
            Divider()
            itemView(title: "估价目的", isRequire: true) { purposePicker }
            Divider()
            itemView(title: "建筑面积", isRequire: true) {
                TextField("请输入建筑面积", text: buildingArea)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
                    .keyboardType(.numberPad)
            }
            Divider()
            itemView(title: "建筑结构", isRequire: true) { structurePicker }
            Divider()
            itemView(title: "联系人", isRequire: true) {
                TextField("请输入联系人", text: $sheet.contact)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
            }
            Divider()
            itemView(title: "移动电话", isRequire: true) {
                TextField("请输入移动电话", text: $sheet.phone)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
                    .keyboardType(.phonePad)
            }
            Divider()
            itemView(title: "估价时间", isRequire: true) { valuationDatePicker }
        }
    }
    
    private var optionalSection: some View {
        SectionView(title: "询价基本信息") {
            itemView(title: "土地面积", isRequire: false) {
                TextField("请输入土地面积", text: landArea)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
                    .keyboardType(.numberPad)
            }
            Divider()
            itemView(title: "建成年份", isRequire: false) {
                HStack {
                    TextField("请输入建成年份", text: $sheet.buildingYear)
                        .multilineTextAlignment(.trailing)
                        .customText(size: 14, color: .text.gray3)
                        .keyboardType(.numberPad)
                    Text("年")
                        .itemContent()
                }
            }
            Divider()
            itemView(title: "地上总层", isRequire: false) {
                HStack {
                    TextField("请输入地上总层", text: upperFloor)
                        .multilineTextAlignment(.trailing)
                        .customText(size: 14, color: .text.gray3)
                        .keyboardType(.numberPad)
                    Text("层")
                        .itemContent()
                }
            }
            Divider()
            itemView(title: "地下总层", isRequire: false) {
                HStack {
                    TextField("请输入地下总层", text: underFloor)
                        .multilineTextAlignment(.trailing)
                        .customText(size: 14, color: .text.gray3)
                        .keyboardType(.numberPad)
                    Text("层")
                        .itemContent()
                }
            }
            Divider()
            itemView(title: "所在楼层", isRequire: false) { floorInput }
            Divider()
            itemView(title: "固定电话", isRequire: false) {
                TextField("请输入固定电话", text: $sheet.telephone)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
                    .keyboardType(.phonePad)
            }
            Divider()
            itemView(title: "业务管理人", isRequire: false) {
                TextField("请输入业务管理人", text: $sheet.custodian)
                    .multilineTextAlignment(.trailing)
                    .customText(size: 14, color: .text.gray3)
            }
        }
    }
    
    private var descriptionSection: some View {
        SectionView(title: "业务描述") {
            TextEditor(text: $sheet.description)
                .frame(height: 100)
        }
    }
    
    private var commentSection: some View {
        SectionView(title: "备注说明") {
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
                        let success = await estateService.addInquiry(sheet: sheet, state: 1)
                        if success {
                            estateService.refreshInquiryList.send(())
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
                        let success = await estateService.addInquiry(sheet: sheet, state: 0)
                        if success {
                            estateService.refreshInquiryList.send(())
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
    
    private var addressString: String {
        "\(sheet.provinceName)\(sheet.cityName)\(sheet.areaName)"
    }
    private var addressPicker: some View {
        HStack {
            Text(addressString.isEmpty ? "请选择物业地址" : addressString)
                .customText(size: 14, color: addressString.isEmpty ? .text.grayCD : .text.gray3)
            Image.main.arrowIconRight
        }
        .plugAreaPicker(
            provinceCode: $sheet.provinceCode,
            provinceName: $sheet.provinceName,
            cityCode: $sheet.cityCode,
            cityName: $sheet.cityName,
            areaCode: $sheet.areaCode,
            areaName: $sheet.areaName
        )
    }
    
    private var estateTypePicker: some View {
        HStack {
            Text(sheet.estateType == nil ? "请选择物业类型" : sheet.estateType?.label ?? "")
                .customText(size: 14,
                            color: sheet.estateType == nil ? .text.grayCD : .text.gray3)
            Image.main.arrowIconRight
        }
        .plugDictTypePicker(optional: $sheet.estateType)
    }
    
    private var purposePicker: some View {
        HStack {
            Text(sheet.purpose == nil ? "请选择估价目的" : sheet.purpose?.label ?? "")
                .customText(size: 14,
                            color: sheet.purpose == nil ? .text.grayCD : .text.gray3)
            Image.main.arrowIconRight
        }
        .plugDictTypePicker(optional: $sheet.purpose)
    }
    
    private var structurePicker: some View {
        HStack {
            Text(sheet.structure == nil ? "请选择建筑结构" : sheet.structure?.label ?? "")
                .customText(size: 14,
                            color: sheet.structure == nil ? .text.grayCD : .text.gray3)
            Image.main.arrowIconRight
        }
        .plugDictTypePicker(optional: $sheet.structure)
    }
    
    private var valuationDatePicker: some View {
        HStack {
            Text(sheet.valuationDate.isEmpty ? "请选择估价时间" : sheet.valuationDate)
                .customText(size: 14,
                            color: sheet.valuationDate.isEmpty ? .text.grayCD : .text.gray3)
            Image.main.arrowIconRight
        }
        .plugDatePicker(date: valuationDate)
    }
    
    private var floorInput: some View {
        HStack {
            TextField("", text: beginFloor)
                .frame(width: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.text.grayCD, lineWidth: 1)
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
            Text("-")
            TextField("", text: endFloor)
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
}

#Preview {
    AddInquiryView(inquiryId: 0, roomDetail: .empty, inquiry: .empty, record: nil)
        .environmentObject(EstateService.preview)
}

struct ImageListView: View {
    @Binding var images: [RpsImage]
    
    @State private var imageInfo = ImagePicker.ImageInfo(image: UIImage(), imageURL: "")
    @State private var showImagePicker = false
    
    private let imagePerRow = 4
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(zip(itemRows.indices, itemRows)), id: \.0) { rowNum, row in
                rowView(items: row, rowNum: rowNum)
            }
        }
        .sheet(isPresented: $showImagePicker, content: {
            ImagePicker(selectedImage: $imageInfo)
        })
        .onChange(of: imageInfo) { newValue in
            images.append(RpsImage.from(pickerImage: imageInfo))
        }
    }
    
    private func rowView(items: [Item], rowNum: Int) -> some View {
        HStack {
            ForEach(Array(zip(items.indices, items)), id: \.0) { idxInRow, item in
                itemView(item: item, idx: rowNum * imagePerRow + idxInRow)
                    .frame(width: 70, height: 70)
            }
            Spacer()
        }
    }
    
    private func itemView(item: Item, idx: Int) -> some View {
        switch item {
        case .image(let image):
            return Image(uiImage: image)
                .resizable()
                .overlay(
                    Button {
                        images.remove(at: idx)
                    } label: {
                        Image.index.removeIcon
                    }
                )
                .earseToAnyView()
        case .button:
            return addButton.earseToAnyView()
        }
    }
    
    private var addButton: some View {
        Button {
            showImagePicker = true
        } label: {
            Image.index.addButton
        }
    }
    
    private enum Item {
        case image(UIImage)
        case button
    }
    
    private var itemRows: [[Item]] {
        var out = [[Item]]()
        var idx = 0
        while idx < images.count {
            if idx+imagePerRow < images.count {
                out.append(images[idx..<idx+imagePerRow].map { Item.image($0.image) })
            } else {
                var l = images[idx..<images.count].map { Item.image($0.image) }
                if idx+imagePerRow == images.count {
                    out.append(l)
                    out.append([Item.button])
                } else {
                    l.append(Item.button)
                    out.append(l)
                }
            }
            idx += imagePerRow
        }
        if out.isEmpty {
            out.append([Item.button])
        }
        return out
    }
}

