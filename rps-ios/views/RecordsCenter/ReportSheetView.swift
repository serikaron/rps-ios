//
//  ReportSheetView.swift
//  rps-ios
//
//  Created by serika on 2023/11/22.
//

import SwiftUI

struct ReportSheetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService

    @State private var sheet = ConsultReportSheet()
    
    let type: Int
    let estateType: String
    let inquiryId: Int
    let reportState: Int
    
    @State private var showPdf = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: ConsultPDF(inquiryId: inquiryId), isActive: $showPdf) {
                EmptyView()
            }
            
            ScrollView {
                VStack {
                    TemplateView(type: type, estateType: estateType, selectedTemplate: $sheet.template)
                    SectionView(title: "选择照片") {
                        ReportImageListView(images: $sheet.images)
                    }
                    InputView(sheet: $sheet)
                    SectionView(title: "备注") {
                        TextEditor(text: $sheet.comment)
                            .frame(height: 100)
                    }
                    Text("报告预览")
                        .customText(size: 16, color: .white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.main)
                        .cornerRadius(8)
                        .padding(.horizontal, 12)
                        .onTapGesture {
                            Task {
                                await estateService.addConsultReport(sheet: sheet, inquiryId: inquiryId, reportState: reportState)
                                showPdf = true
                            }
                        }
                }
                .padding(.vertical, 10)
            }
            .background(Color.view.background)
        }
        .setupNavigationBar(title: "获取报告单") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ReportSheetView(type: 0, estateType: DictType.EstateType.commApartment.dictKey, inquiryId: 0, reportState: 2)
        .environmentObject(EstateService.preview)
}

private struct TemplateView: View {
    @EnvironmentObject var estateService: EstateService
    
    let type: Int
    let estateType: String
    
    @State private var templateList: [Template] = []
    @State private var templateItems: [TemplateItem] = []
    
    @Binding var selectedTemplate: Template?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("选择模板").headerText()
            Spacer().frame(height: 20)
            HStack {
                Text("模板名称").itemTitle()
                Menu {
                    ForEach(templateList, id: \.id) { t in
                        Button {
                            selectedTemplate = t
                        } label: {
                            Text(t.name).itemContent()
                        }
                    }
                } label: {
                    Text(selectedTemplate == nil ? "请选择模板" : selectedTemplate!.name)
                        .customText(
                            size: 14,
                            color: selectedTemplate == nil ? .text.grayCD : .text.gray6)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image.main.arrowIconRight
                }
            }
            Spacer().frame(height: 16)
            Divider()
            Spacer().frame(height: 20)
            VStack {
                ForEach(templateItemRows, id: \.id) { r in
                    templateRow(titleL: r.titleL, titleR: r.titleR)
                }
            }
        }
        .sectionStyle()
        .onAppear {
            Task {
                templateList = await estateService.getTemplates(type: type, estateType: estateType)
            }
        }
        .onChange(of: selectedTemplate) { newValue in
            guard let tmpl = newValue else { return }
            Task {
                templateItems = await estateService.getTemplate(id: tmpl.id)
            }
        }
    }
    
    private func templateItemView(title: String) -> some View {
        HStack {
            Image.records.checked
            Text(title).itemContent()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func templateRow(titleL: String, titleR: String) -> some View {
        HStack {
            templateItemView(title: titleL)
            if !titleR.isEmpty {
                templateItemView(title: titleR)
            }
        }
    }
    
    struct Row {
        let id: Int
        let titleL: String
        let titleR: String
    }
    
    private var templateItemRows: [Row] {
        var out = [Row]()
        
        var idx = 0
        while idx < templateItems.count {
            if idx + 2 < templateItems.count {
                out.append(Row(id: idx, titleL: templateItems[idx].name, titleR: templateItems[idx+1].name))
            } else {
                out.append(Row(id: idx, titleL: templateItems[idx].name, titleR: ""))
            }
            idx += 2
        }
        
        return out
    }
}

//#Preview("template") {
//    TemplateView()
//        .environmentObject(EstateService.preview)
//}

private struct ReportImageListView: View {
    @Binding var images: [RpsImage]
    
    @State private var imageInfo = ImagePicker.ImageInfo(image: UIImage(), imageURL: "")
    @State private var showImagePicker = false
    
    private let imagePerRow = 3
    
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
            var filename = ""
            if let url = URL(string: imageInfo.imageURL) {
                filename = url.lastPathComponent
            } else {
                filename = UUID().uuidString
            }
            images.append(RpsImage(image: imageInfo.image, filename: filename))
        }
    }
    
    private func rowView(items: [Item], rowNum: Int) -> some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(items.indices, items)), id: \.0) { idxInRow, item in
                itemView(item: item, idx: rowNum * imagePerRow + idxInRow)
                    .frame(width: 100, height: 131)
            }
        }
        .frame(width: 340, alignment: .leading)
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
                        Image.records.remove
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
            Image.records.add
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

//#Preview("image") {
//    ReportImageListView()
//        .background(Color.black)
//}

private struct InputView: View {
    @Binding var sheet: ConsultReportSheet
    
    var body: some View {
        SectionView(title: "输入打印信息") {
            textItemView(title: "银行客户经理", isRequire: false, binding: $sheet.bankManager)
            textItemView(title: "部门", isRequire: false, binding: $sheet.dept)
            textItemView(title: "客户名称", isRequire: true, binding: $sheet.clientName)
            doubleInputView(title: "土地面积", isRequire: true, binding: $sheet.landArea, subFix: "m²")
            textItemView(title: "房屋所有权证号", isRequire: false, binding: $sheet.houseNum)
            textItemView(title: "土地使用权证号", isRequire: false, binding: $sheet.landNum)
            doubleInputView(title: "房屋套内面积", isRequire: false, binding: $sheet.houseArea, subFix: "m²")
            textItemView(title: "房屋质量", isRequire: false, binding: $sheet.quality)
            dateItemView(title: "土地终止日期", isRequire: false, binding: $sheet.landEndDate)
            dictTypeItemView(title: "使用权类型", isRequire: false, allCases: DictType.LandUser.allCases, binding: $sheet.landUser)
            dictTypeItemView(title: "地类用途", isRequire: false, allCases: DictType.LandSe.allCases, binding: $sheet.landSe)
            textItemView(title: "房屋受让人", isRequire: false, binding: $sheet.transferTo)
            textItemView(title: "项目1", isRequire: false, binding: $sheet.item1)
            textItemView(title: "项目2", isRequire: false, binding: $sheet.item2)
        }
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
}

//#Preview("input") {
//    InputView()
//}

