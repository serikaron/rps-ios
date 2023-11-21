//
//  RecordsCenterView.swift
//  rps-ios
//
//  Created by serika on 2023/11/21.
//

import SwiftUI

struct RecordsCenterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var param = SearchParam()
    @State private var moreSheetShown = false
    @State private var maskAlpha: Double = .zero
    @State private var sheetOffset: Double = 300
    
    var body: some View {
        NavigationView {
            ZStack {
                content
                Color.black.opacity(maskAlpha)
                    .onTapGesture {
                        moreSheetShown = false
                    }
                    .ignoresSafeArea()
                MoreFilterView(param: $param, shown: $moreSheetShown)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(x: 0, y: sheetOffset)
                    .ignoresSafeArea()
            }
            .navigationTitle("询价记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("委托记录")
                        .customText(size: 14, color: .hex("#2A64D6"))
                }
            }
            .onChange(of: moreSheetShown) { shown in
                withAnimation(.linear(duration: 0.2)) {
                    maskAlpha = shown ? 0.6 : 0
                    sheetOffset = shown ? 0 : 300
                }
            }
        }
    }
    
    private var content: some View {
        VStack {
            header
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
                menu(title: "记录类型", allCases: RecordType.allCases, binding: $param.recordType)
                menu(title: "物业类型", allCases: DictType.EstateType.allCases, binding: $param.estateType)
                menu(title: "询价系统", allCases: InquiryType.allCases, binding: $param.inquiryType)
                menu(title: "业务状态", allCases: InquiryState.allCases, binding: $param.inquiryState)
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

private enum RecordType: CaseIterable, HasLabel {
    case personal, organize
    
    var label: String {
        switch self {
        case .organize: return "单位记录"
        case .personal: return "个人记录"
        }
    }
}

private enum InquiryType: CaseIterable, HasLabel {
    case system, manual
    
    var label: String {
        switch self {
        case .system: return "系统询价"
        case .manual: return "人工询价"
        }
    }
}

private enum InquiryState: CaseIterable, HasLabel {
    case _0, _1, _2, _3, _4, _5
    
    var label: String {
        switch self {
        case ._0: return "未提交"
        case ._1: return "待分配"
        case ._2: return "待接受"
        case ._3: return "询价中"
        case ._4: return "已报价"
        case ._5: return "已撤消"
        }
    }
}

private struct SearchParam {
    var address: String = ""
    var recordType: RecordType?
    var estateType: DictType.EstateType?
    var inquiryType: InquiryType?
    var inquiryState: InquiryState?
    var startDate: String = ""
    var endDate: String = ""
    var startPrice: String = ""
    var endPrice: String = ""
    var clientName: String = ""
}

#Preview("main") {
    RecordsCenterView()
}

private struct MoreFilterView: View {
    @Binding var param: SearchParam
    @Binding var shown: Bool
    
    @State private var height: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            Text("更多筛选")
                .customText(size: 14, color: .black)
            Spacer().frame(height: 23)
            VStack(alignment: .trailing, spacing: 16) {
                HStack {
                    Text("估价时间")
                    HStack {
                        dateButton(placeholder: "开始时间", binding: $param.startDate)
                        dateButton(placeholder: "结束时间", binding: $param.endDate)
                    }.frame(width: 255)
                }
                HStack {
                    Text("评估价格")
                    HStack {
                        priceInput(placeholder: "", binding: $param.startPrice)
                        priceInput(placeholder: "", binding: $param.endPrice)
                    }.frame(width: 255)
                }
                HStack {
                    Text("询价人")
                    TextField("询价人", text: $param.clientName)
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
                        param = SearchParam()
                        shown = false
                    }
                Spacer()
                Text("搜索")
                    .customText(size: 16, color: .white)
                    .frame(width: 130, height: 40)
                    .background(Color.main)
                    .cornerRadius(8)
                    .onTapGesture {
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
    MoreFilterView(param: .constant(SearchParam()), shown: .constant(false))
}
