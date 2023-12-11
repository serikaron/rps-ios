//
//  RecordsCenterView.swift
//  rps-ios
//
//  Created by serika on 2023/11/21.
//

import SwiftUI
import SBPAsyncImage

struct RecordsCenterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    
    @State private var page = RecordPage.inquiry(SearchFilter())
    @State private var param = SearchFilter()
    @State private var moreSheetShown = false
    @State private var maskAlpha: Double = .zero
    @State private var sheetOffset: Double = 500
    @State private var popupRecord: Record?
    
    var body: some View {
        NavigationView {
            ZStack {
                content
                Color.black.opacity(maskAlpha)
                    .onTapGesture {
                        moreSheetShown = false
                    }
//                    .ignoresSafeArea()
                MoreFilterView(param: $param, shown: $moreSheetShown)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(x: 0, y: sheetOffset)
//                    .ignoresSafeArea()
                RecordPopupView(record: $popupRecord)
                    .opacity(popupRecord == nil ? 0 : 1)
            }
            .navigationTitle(page.viewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(page.buttonTitle)
                        .customText(size: 14, color: .hex("#2A64D6"))
                        .onTapGesture {
                            (page, param) = page.toggle(filter: param)
                        }
                }
            }
            .onChange(of: moreSheetShown) { shown in
                withAnimation(.linear(duration: 0.2)) {
                    maskAlpha = shown ? 0.6 : 0
                    sheetOffset = shown ? 0 : 500
                    if !shown {
                        hideKeyboard()
                    }
                }
            }
            .onDisappear {
                popupRecord = nil
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            RecordListView(page: $page, filter: $param, popupRecord: $popupRecord)
        }
        .background(Color.view.background)
    }
    
    private var header: some View {
        VStack {
            inputView
            Divider()
            filterInfoView
        }
        .background(Color.white)
    }
    
    private var inputView: some View {
        VStack {
            HStack {
                Image.main.searchIcon
                TextField("输入物业地址", text: $param.address)
                    .customText(size: 14, color: .text.gray3)
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Color.hex("#F7F7F7"))
            .cornerRadius(18)
            .padding(.horizontal, 16)
            
            HStack {
//                menu(title: "记录类型", allCases: RecordType.allCases, binding: $param.recordType)
                Menu {
                    Picker("", selection: $param.recordType) {
                        ForEach(RecordType.allCases, id: \.self) { type in
                            Text(type.label)
                                .customText(size: 14, color: param.recordType == type ? .main : .green)
                        }
                    }
                } label: {
                    HStack(spacing: 0) {
                        Text("记录类型")
                            .customText(size: 14, color: .main)
                        Image.main.arrowIconDown
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                }

                menu(title: "物业类型", allCases: DictType.EstateType.allCases, binding: $param.estateType)
                Group {
                    switch page {
                    case .inquiry:
                        menu(title: "询价系统", allCases: InquiryType.allCases, binding: $param.inquiryType)
                    case .report:
                        EmptyView()
                    }
                }
                Group {
                    switch page {
                    case .inquiry:
                        menu(title: "业务状态", allCases: InquiryState.allCases, binding: $param.inquiryState)
                    case .report:
                        menu(title: "业务状态", allCases: [
                            ReportState._0, ._2, ._3, ._6, ._7
                        ], binding: $param.reportState)
                    }
                }
                Spacer()
                Image.records.more
                    .onTapGesture {
                        moreSheetShown = true
                    }
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .padding(.horizontal, 16)
            
        }
    }
    
    private var filterInfoView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("估价时间").itemContent()
                Text("\(param.startDate) — \(param.endDate)")
                    .itemTitle()
                Spacer()
            }
            HStack {
                Text("评估价格").itemContent()
                Text("\(param.startPrice)元 — \(param.endPrice)元")
                    .itemTitle()
            }
            HStack {
                Text("询价人").itemContent()
                Text(param.clientName).itemTitle()
            }
            HStack {
                Text("物业地址").itemContent()
                Text(param.address).itemTitle()
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
    }
    
    private func menu<T: Hashable & HasLabel>(title: String, allCases: [T?], binding: Binding<T?>) -> some View {
        Menu {
            Picker("", selection: binding) {
                ForEach([.none] + allCases, id: \.self) { type in
                    Text(type?.label ?? "全部")
                        .customText(size: 14, color: binding.wrappedValue == type ? .main : .green)
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text(title)
                    .customText(size: 14, color: .main)
                Image.main.arrowIconDown
                    .resizable()
                    .frame(width: 14, height: 14)
            }
        }
    }
}

//private extension RecordPage {
//    func stateMenu(: some View {
//        switch self {
//        case .inquiry:
//            return menu(title: "业务状态", allCases: InquiryState.allCases, binding: $param.inquiryState)
//                .earseToAnyView()
//        case .report:
//            return menu(title: "业务状态", allCases: [
//                ReportState._0, ._2, ._3, ._6, ._7
//            ], binding: $param.inquiryState)
//            .earseToAnyView()
//        }
//    }
//}


#Preview("main") {
    RecordsCenterView()
        .environmentObject(EstateService.preview)
}

private struct MoreFilterView: View {
    @Binding var param: SearchFilter
    @Binding var shown: Bool
    
    @State private var height: CGFloat = .zero
    @State private var newFilter = SearchFilter()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("更多筛选")
                .customText(size: 14, color: .black)
            Spacer().frame(height: 23)
            VStack(alignment: .trailing, spacing: 16) {
                HStack {
                    Text("估价时间")
                    HStack {
                        dateButton(placeholder: "开始时间", binding: $newFilter.startDate)
                        dateButton(placeholder: "结束时间", binding: $newFilter.endDate)
                    }.frame(width: 255)
                }
                HStack {
                    Text("评估价格")
                    HStack {
                        priceInput(placeholder: "", binding: $newFilter.startPrice)
                        priceInput(placeholder: "", binding: $newFilter.endPrice)
                    }.frame(width: 255)
                }
                HStack {
                    Text("询价人")
                    TextField("询价人", text: $newFilter.clientName)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 8)
                        .frame(width: 255, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.hex("#F2F2F2"))
                        )
                }
            }
            .itemTitle()
            Spacer().frame(height: 36)
            HStack {
                Spacer()
                Text("重置")
                    .customText(size: 16, color: .main)
                    .frame(width: 130, height: 40)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main, lineWidth: 1)
                    )
                    .onTapGesture {
                        newFilter = SearchFilter()
                    }
                Spacer()
                Text("搜索")
                    .customText(size: 16, color: .white)
                    .frame(width: 130, height: 40)
                    .background(Color.main)
                    .cornerRadius(8)
                    .onTapGesture {
                        param = newFilter
                        shown = false
                    }
                Spacer()
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .padding(.bottom, 49+34)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private func dateButton(placeholder: String, binding: Binding<String>) -> some View {
        HStack {
            Text(binding.wrappedValue.isEmpty ? "开始时间" : binding.wrappedValue)
                .foregroundColor(binding.wrappedValue.isEmpty ? .text.grayCD : .text.gray3)
            Spacer()
            Image.main.calendarIcon
        }
        .padding(.horizontal, 8)
        .frame(height: 28)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.hex("#F2F2F2"))
        )
        .overlay(
            DatePicker("", selection: Binding(
                get: { binding.wrappedValue.toDate() ?? Date() },
                set: { binding.wrappedValue = $0.toString() }
            ), displayedComponents: [.date])
            .blendMode(.destinationOver)
        )
    }
    
    private func priceInput(placeholder: String, binding: Binding<String>) -> some View {
        TextField(placeholder, text: binding)
            .keyboardType(.numberPad)
            .padding(.horizontal, 8)
            .frame(height: 28)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.hex("#F2F2F2"))
            )
    }
}

#Preview("MoreFilter") {
    MoreFilterView(param: .constant(SearchFilter()), shown: .constant(false))
}

private struct RecordView: View {
    @EnvironmentObject var tabService: TabService
    @EnvironmentObject var estateService: EstateService
    
    let record: Record
    @Binding var popupRecord: Record?
    
    var body: some View {
        VStack(spacing: 0) {
            infoView
            Divider()
            buttonView
        }
        .background(Color.white)
        .padding(.horizontal, 12)
        .cornerRadius(8)
    }
    
    private var infoView: some View {
        HStack(spacing: 0) {
            BackportAsyncImage(url: URL(string: record.imageURL)) { image in
                image.resizable()
            } placeholder: {
//                Image.main.placeholder.resizable()
                Color.gray
            }
            .frame(width: 100, height: 136)
            .cornerRadius(8)

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(record.address).headerText()
                    Spacer().frame(height: 4)
                    HStack {
                        if let inquiryType = record.inquiryType {
                            colorText(inquiryType.label)
                        }
                        colorText(record.district)
                        colorText(record.estateType.label)
                    }
                    Spacer().frame(height: 9)
                    HStack(spacing: 30) {
                        VStack(spacing: 8) {
                            Text("询价人: \(record.clientName)")
                            Text(record.valuationDate)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            switch record.page {
                            case .inquiry:
                                Text(record.inquiryState!.label)
                            case .report:
                                Text(record.reportState!.label)
                            }
                            Text(record.downloadState?.label ?? "")
                        }
                    }
                    .customText(size: 12, color: .text.gray6)
                }
                Spacer().frame(height: 8)
                HStack {
                    VStack {
                        Text("总价")
                        Text("\(record.displayTotalPrice)万元")
                    }
                    Spacer()
                    VStack {
                        Text("单价")
                        Text("\(record.price)元/m²")
                    }
                    Spacer()
                    VStack {
                        Text("面积")
                        Text("\(record.area)平方米")
                    }
                }
                .customText(size: 12, color: .text.gray6)
            }
            .padding(.horizontal, 14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
    
    private func colorText(_ text: String) -> some View {
        Text(text)
            .customText(size: 12, color: .main)
            .padding(.horizontal, 6)
            .frame(height: 19)
            .background(Color.hex("#E8EFFC"))
            .cornerRadius(4)
    }
    
    private var buttonView: some View {
        switch record.page {
        case .inquiry:
            return buttonViewInquiry.earseToAnyView()
        case .report:
            return buttonViewReport.earseToAnyView()
        }
    }
    
    private var buttonViewInquiry: some View {
        ScrollView(.horizontal) {
            HStack {
                NavigationLink {
                    ReportSheetView(type: record.inquiryType!.dictKey, estateType: record.estateType.dictKey, inquiryId: record.id, reportState: 2)
                } label: {
                    Text("获到报告单")
                }
                    .disabled(button1Disabled)
                NavigationLink {
                    RoomDetailView(
                        familyRoomName: record.address,
                        areaCode: record.areaCode,
                        estateType: record.estateType.dictKey,
                        buildingId: record.buildingId,
                        area: "",
                        floor: record.floor)
                } label: {
                    Text("重新估价")
                }
                .disabled(button2Disabled)
                NavigationLink {
                    AddReportView(inquiry: nil, detail: nil)
                } label: {
                    Text("提交委托")
                }
                .disabled(button3Disabled)
                Button("撤消询价") {
                    Task {
                        await estateService.withdrawInquiry(id: record.id)
                    }
                }
                    .disabled(button4Disabled)
                NavigationLink {
                    AddInquiryView(inquiry: nil, record: record)
                } label: {
                    Text("提交询价")
                }
                .disabled(button5Disabled)
                Button("客户咨询") {
                    tabService.selectedTab = .cs
                }
                    .disabled(button6Disabled)
            }
        }
        .font(.system(size: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }
    
    private var button1Disabled: Bool {
        switch (record.inquiryType, record.inquiryState) {
        case (_, ._4): return false
        default: return true
        }
    }
    
    private var button2Disabled: Bool {
        switch (record.inquiryType, record.inquiryState) {
        case (.system, ._3): fallthrough
        case (.system, ._4): fallthrough
        case (.manual, ._4):
            return false
        default: return true
        }
    }
    
    private var button3Disabled: Bool {
        switch (record.inquiryType, record.inquiryState) {
        case (.system, ._3): fallthrough
        case (.system, ._4): fallthrough
        case (.manual, ._4):
            return false
        default: return true
        }
    }
    
    private var button4Disabled: Bool {
        switch (record.inquiryType, record.inquiryState) {
        case (.manual, ._1): fallthrough
        case (.manual, ._2): fallthrough
        case (.manual, ._3):
            return false
        default: return true
        }
    }
    
    private var button5Disabled: Bool {
        switch (record.inquiryType, record.inquiryState) {
        case (.system, ._3): fallthrough
        case (.system, ._4): fallthrough
        case (.manual, ._0): fallthrough
        case (.manual, ._5):
            return false
        default: return true
        }
    }
    
    private var button6Disabled: Bool {
        switch (record.inquiryType, record.inquiryState) {
        case (.system, ._4): fallthrough
        case (.manual, ._1): fallthrough
        case (.manual, ._2): fallthrough
        case (.manual, ._3): fallthrough
        case (.manual, ._4):
            return false
        default: return true
        }
    }
    
    private var buttonViewReport: some View {
        ScrollView(.horizontal) {
            HStack {
                NavigationLink {
                    AddReportView(inquiry: nil, detail: nil)
                } label: {
                    Text("提交委托")
                }
                .disabled(reportButton1Disabled)
                Button("撤消询价") {
                    Task {
                        await estateService.withdrawInquiry(id: record.id)
                    }
                }
                .disabled(reportButton2Disabled)
                Button("查看结果") {
                    withAnimation {
                        popupRecord = record
                    }
                }
                    .disabled(reportButton3Disabled)
                Button("客户咨询") {
                    tabService.selectedTab = .cs
                }
                    .disabled(reportButton4Disabled)
            }
        }
        .font(.system(size: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }
    
    private var reportButton1Disabled: Bool {
        switch record.reportState {
        case ._0: fallthrough
        case ._7:
            return false
        default: return true
        }
    }
    
    private var reportButton2Disabled: Bool {
        switch record.reportState {
        case ._1: fallthrough
        case ._2: fallthrough
        case ._3: fallthrough
        case ._4: fallthrough
        case ._5:
            return false
        default: return true
        }
    }
    
    private var reportButton3Disabled: Bool {
        switch record.reportState {
        case ._6:
            return false
        default: return true
        }
    }
    
    private var reportButton4Disabled: Bool {
        switch record.reportState {
        case ._1: fallthrough
        case ._2: fallthrough
        case ._3: fallthrough
        case ._4: fallthrough
        case ._5: fallthrough
        case ._6: fallthrough
        case ._7:
            return false
        default: return true
        }
    }
}

#Preview("Record") {
    RecordView(record: Record.mock, popupRecord: .constant(nil))
}

private struct RecordListView: View {
    @EnvironmentObject var estateService: EstateService
    
    @State private var pageSize = 10
    @State private var pageNum = 0
    @State private var records: [Record] = []
    @State private var total = Int.max
    @Binding var page: RecordPage
    @Binding var filter: SearchFilter
    @Binding var popupRecord: Record?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(Array(zip(records.indices, records)), id: \.0) { idx, r in
                    RecordView(record: r, popupRecord: $popupRecord)
                        .onAppear {
                            if idx == records.count - 2 {
                                getRecord()
                            }
                        }
                }
            }
        }
        .padding(.vertical, 10)
        .onAppear {
            getRecord()
        }
        .onChange(of: page) { newValue in
            pageNum = 0
            records = []
            getRecord()
        }
        .onChange(of: filter) { _ in
            pageNum = 0
            records = []
            getRecord()
        }
    }
    
    private func getRecord() {
        Task {
            guard records.count < total else { return }
            
            let r = await estateService.getRecords(pageNum: pageNum + 1, pageSize: pageSize, filter: filter, page: page)
            guard r.current == pageNum + 1 else { return }
            records.append(contentsOf: r.records)
            pageNum = r.current
            total = r.total
        }
    }
}

private struct RecordPopupView: View {
    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var accountService: AccountService
    
    @Binding var record: Record?
    @State private var showPdf = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: ComplexPDF(id: record?.id ?? 0), isActive: $showPdf) {
                EmptyView()
            }
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hide()
                }
            
            VStack {
                Image.index.close
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 12)
                    .onTapGesture {
                        hide()
                    }
                Spacer().frame(height: 20)
                HStack {
                    NavigationLink {
                        ReportSheetView(type: record?.inquiryType?.dictKey ?? 0, estateType: record?.estateType.dictKey ?? "", inquiryId: record?.id ?? 0, reportState: 1)
                    } label: {
                        Text("直接下载")
                            .customText(size: 16, color: .main)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.main, lineWidth: 1)
                            )
                            .onTapGesture {
                                showPdf = true
                            }
                    }
                    Text("发送邮箱")
                        .customText(size: 16, color: .white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.main)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            Task {
                                if let record = record {
                                    await estateService.sendReportToMail(id: "\(record.id)", email: accountService.account?.email ?? "")
                                }
                                hide()
                            }
                        }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 12)
            .padding(.bottom, 45)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 30)
        }
    }
    
    private func hide() {
        withAnimation {
            record = nil
        }
    }
}

#Preview("popup") {
    RecordPopupView(record: .constant(nil))
        .environmentObject(EstateService.preview)
        .environmentObject(AccountService.preview)
}

private extension RecordPage {
    var viewTitle: String {
        switch self {
        case .inquiry:
            return "询价记录"
        case .report:
            return "委托记录"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .report:
            return "询价记录"
        case .inquiry:
            return "委托记录"
        }
    }
    
    func toggle(filter: SearchFilter) -> (RecordPage, SearchFilter) {
        switch self {
        case .inquiry(let outFiler):
            return (RecordPage.report(filter), outFiler)
        case .report(let outFilter):
            return (RecordPage.inquiry(filter), outFilter)
        }
    }
}

extension RecordPage: Equatable {
    static func == (lhs: RecordPage, rhs: RecordPage) -> Bool {
        switch (lhs, rhs) {
        case (.inquiry, .inquiry): return true
        case (.report, .report): return true
        default: return false
        }
    }
}
