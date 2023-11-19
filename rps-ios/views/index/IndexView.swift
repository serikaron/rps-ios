//
//  IndexView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI
import DGCharts
import SBPAsyncImage

struct IndexView: View {
    @EnvironmentObject var accountService: AccountService
    
    @State private var noticeList = [Notice]()
    @State private var curves: [Curve] = []
    @State private var isChoisesShown = false
    @State private var chartCurveType = ChartCurveType.district(startTime: nil, endTime: nil)
    @State private var estateType = DictType.EstateType.commApartment
    
    var body: some View {
        ZStack {
            NavigationView {
                content
                    .navigationTitle("首页")
                    .navigationBarTitleDisplayMode(.inline)
                //                .ignoresSafeArea(edges: .bottom)
                    .onAppear {
                        Task {
                            noticeList = await Notice.list(pageNum: 1, pageSize: 10, orgId: accountService.account?.orgId ?? 0)
                        }
                    }
                
            }
            if isChoisesShown {
                Color.white.opacity(0.01)
                    .onTapGesture {
                        isChoisesShown = false
                    }
                ChartChoisesView(selectedCurve: $chartCurveType)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.bottom, 40)
                    .padding(.trailing, 40)
            }
        }
        .onChange(of: estateType) { newValue in
            Task {
                curves = await chartCurveType.getCurve(unitId: accountService.account?.unitId ?? 0, estateType: estateType.dictKey)
            }
        }
        .onChange(of: chartCurveType) { newValue in
            Task {
                curves = await chartCurveType.getCurve(unitId: accountService.account?.unitId ?? 0, estateType: estateType.dictKey)
            }
        }
        .onAppear {
            Task {
                curves = await chartCurveType.getCurve(unitId: accountService.account?.unitId ?? 0, estateType: estateType.dictKey)
            }
        }
    }
    
    var content: some View {
        ZStack {
            Color.view.background
            VStack(alignment: .center, spacing: 0) {
                BannerView()
                    .frame(height: 150)
                    .cornerRadius(8)
                Spacer().frame(height: 10)
                noticeSection
                Spacer().frame(height: 16)
                actionSection
                Spacer().frame(height: 16)
                searchSection
//                Spacer()
            }
            .padding(.top, 15)
            .padding(.horizontal, 12)
            
        }
    }
    
    private var noticeTitle: String {
        if noticeList.isEmpty {
            return ""
        } else {
            return noticeList[0].title
        }
    }
    
    private var noticeSection: some View {
        Color.white
            .frame(height: 38)
            .cornerRadius(8)
            .overlay (
                HStack(spacing: 10) {
                    Image.index.announceIcon
                    Text(noticeTitle)
                        .customText(size: 14, color: .text.gray3)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .padding(.horizontal, 16)
            )
    }
    
    private var actionSection: some View {
        HStack {
            NavigationLink {
                Text("SubView")
            } label: {
                actionButtonView(title: "估价师询价", subTitle: "Appraiser Inquiry", icon: .index.inquiryIcon)
            }
            Spacer()
            actionButtonView(title: "新建委托", subTitle: "New commission", icon: .index.commissionIcon)
        }
    }
    
    private func actionButtonView(title: String, subTitle: String, icon: Image) -> some View {
        return ZStack {
            Image.index.buttonBg
            HStack {
                VStack(spacing: 2) {
                    Text(title).customText(size: 16, color: .main, weight: .bold)
                    Text(subTitle.uppercased()).customText(size: 8, color: .text.gray9)
                }
                Spacer()
                icon.frame(width: 50, height: 50)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 165, height: 66)
        }
    }
    
    private var searchSection: some View {
        return VStack(spacing: 0) {
            searchAction
            searchResult
        }
    }
    
    private var searchAction: some View {
        return searchInput
            .padding(.horizontal, 16)
            .padding(.top, 28)
            .padding(.bottom, 28)
            .background(
                Color(hex: "#EDF1FF").opacity(0.5)
                    .cornerRadius(8)
                    .shadow(color: Color(hex: "#C8C8C8").opacity(0.25), radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            )
    }
    
    private var searchInput: some View {
        return NavigationLink {
            FuzzySearchView()
        } label: {
            HStack(spacing: 0) {
                Image.index.searchOCR
                Spacer().frame(width: 10)
                Text("请输入物业名称或地址")
                    .customText(size: 14, color: .text.grayCD)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer().frame(width: 10)
                Image.main.searchIcon
            }
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(Color.white)
            .cornerRadius(18)
        }
    }
    
    private var searchLocation: some View {
        return Color.white
            .overlay(
                HStack(spacing: 0, content: {
                    searchLocationButton(title: "浙江省")
                    Spacer().frame(width: 20)
                    searchLocationButton(title: "温州市")
                    Spacer().frame(width: 20)
                    searchLocationButton(title: "主城区")
                    Spacer()
                    Image.index.searchGIS
                    Spacer().frame(width: 10)
                    VerticalDivider(length: 6)
                    Spacer().frame(width: 10)
                    Image.main.searchIcon
                })
                    .padding(.horizontal, 16)
            )
            .frame(height: 36)
            .cornerRadius(18)
    }
    
    private func searchLocationButton(title: String) -> some View {
        return HStack(spacing: 2) {
            Text(title)
                .customText(size: 14, color: .text.gray3)
            Image.main.arrowIcon
                .renderingMode(.template)
                .resizable()
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(-90))
                .foregroundColor(Color(hex: "#CDCDCD"))
        }
    }
    
    private var searchResult: some View {
        VStack {
            ChartTabView(selected: $estateType)
            ChartView(curves: $curves)
            HStack {
                HStack {
                    Image.index.pointIcon
                    Text("价格走势")
                        .customText(size: 14, color: .text.gray3)
                }
                Spacer()
                Button {
                    isChoisesShown = true
                } label: {
                    HStack {
                        Image.index.editIcon
                        Text("编辑指标")
                            .customText(size: 14, color: .main)
                    }
                }
            }
        }
        .padding()
//        .padding(.bottom, 49)
        .background(
            Color.white
                .cornerRadius(8)
        )
    }
}

#Preview {
    IndexView()
        .environmentObject(AccountService())
}

private struct ChartTabView: View {
    @Binding var selected: DictType.EstateType
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 35) {
                ForEach(DictType.EstateType.allCases, id: \.self) { tab in
                    Button {
                        selected = tab
                    } label: {
                        if tab == selected {
                            VStack {
                                Text(tab.label).customText(size: 14, color: .main)
                                Color.main.frame(width: 20, height: 3)
                            }
                        } else {
                            VStack {
                                Text(tab.label).customText(size: 14, color: .text.gray3)
                                Spacer()
                            }
                        }
                    }
                }
            }
//            .padding(.horizontal, 16)
            .frame(height: 30)
        }
    }
}


private struct BannerView: View {
    @State private var selected: Int = 1
    @State private var banners: [Banner] = []
    
    private var bannerURLs: [URL] {
        banners.compactMap { URL(string: $0.ossUrl) }
    }
    
    var body: some View {
        TabView {
            if bannerURLs.isEmpty {
                Image.main.placeholder
            } else {
                ForEach(bannerURLs, id: \.self) { bannerURL in
                    BackportAsyncImage(url: bannerURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .clipped()
                    } placeholder: {
                        Image.main.placeholder
                    }
                }
            }
        }
    }
}

//#Preview("banner") {
//    BannerView()
//}

private enum ChartCurveType: Equatable {
    case district(startTime: String?, endTime: String?),
         combined(startTime: String?, endTime: String?),
         districtAndCombined(startTime: String?, endTime: String?)
    
    static var allCases: [ChartCurveType] {
        [
            district(startTime: nil, endTime: nil),
            combined(startTime: nil, endTime: nil),
            districtAndCombined(startTime: nil, endTime: nil)
        ]
    }
    
    var text: String {
        switch self {
        case .district:
            return "区县曲线"
        case .combined:
            return "合并曲线"
        case .districtAndCombined:
            return "区县曲线及合并曲线"
        }
    }
    
    var time: (startTime: String, endTime: String) {
        switch self {
        case .district(let startTime, let endTime):
            return unwrapTime(startTime: startTime, endTime: endTime)
        case .combined(let startTime, let endTime):
            return unwrapTime(startTime: startTime, endTime: endTime)
        case .districtAndCombined(let startTime, let endTime):
            return unwrapTime(startTime: startTime, endTime: endTime)
        }
    }
    
    func filled(startTime: String?, endTime: String?) -> ChartCurveType {
        switch self {
        case .district:
            return .district(startTime: startTime, endTime: endTime)
        case .combined:
            return .combined(startTime: startTime, endTime: endTime)
        case .districtAndCombined:
            return .districtAndCombined(startTime: startTime, endTime: endTime)
        }
    }
    
    func getCurve(unitId: Int, estateType: String) async -> [Curve] {
        switch self {
        case .district(let startTime, let endTime):
            let (s, e) = unwrapTime(startTime: startTime, endTime: endTime)
            return [await Curve.districtCurve(unitId: unitId, startTime: s, endTime: e, estateType: estateType)]
        case .combined(let startTime, let endTime):
            let (s, e) = unwrapTime(startTime: startTime, endTime: endTime)
            return [await Curve.combinedCurve(unitId: unitId, startTime: s, endTime: e, estateType: estateType)]
        case .districtAndCombined(let startTime, let endTime):
            let (s, e) = unwrapTime(startTime: startTime, endTime: endTime)
            return [
                await Curve.districtCurve(unitId: unitId, startTime: s, endTime: e, estateType: estateType),
                await Curve.combinedCurve(unitId: unitId, startTime: s, endTime: e, estateType: estateType)
            ]
        }
    }
    
    private func unwrapTime(startTime: String?, endTime: String?) -> (startTime: String, endTime: String) {
        switch (startTime, endTime) {
        case (.some(let s), .none):
            guard let date = s.toDate(format: "YYYY-MM")
            else { return defaultTime }
            
            var dc = DateComponents()
            dc.month = 11
            if let end = Calendar.current.date(byAdding: dc, to: date) {
                return (startTime: date.toString(format: "YYYY-MM"),
                        endTime: end.toString(format: "YYYY-MM"))
            } else {
                return (startTime: date.toString(format: "YYYY-MM"),
                        endTime: date.toString(format: "YYYY-MM"))
            }
        case (.none, .some(let e)):
            guard let date = e.toDate(format: "YYYY-MM")
            else { return defaultTime }
            
            var dc = DateComponents()
            dc.month = -11
            if let start = Calendar.current.date(byAdding: dc, to: date) {
                return (startTime: date.toString(format: "YYYY-MM"),
                        endTime: start.toString(format: "YYYY-MM"))
            } else {
                return (startTime: date.toString(format: "YYYY-MM"),
                        endTime: date.toString(format: "YYYY-MM"))
            }
        case (.none, .none): return defaultTime
        case (.some(let s), .some(let e)): return (s, e)
        }
    }
    
    private var defaultTime: (startTime: String, endTime: String) {
        let endDate = Date()
        var dc = DateComponents()
        dc.month = -11
        if let startDate = Calendar.current.date(byAdding: dc, to: endDate) {
            return (startTime: startDate.toString(format: "YYYY-MM"),
                    endTime: endDate.toString(format: "YYYY-MM"))
        } else {
            return (startTime: endDate.toString(format: "YYYY-MM"),
                    endTime: endDate.toString(format: "YYYY-MM"))
        }
    }
}

private struct ChartChoisesView: View {
    @Binding var selectedCurve: ChartCurveType
    
    @State private var startTimePickerShown = false
    @State private var endTimePickerShown = false
    
    @State private var startTime: String?
    @State private var endTime: String?
    @State private var curve: ChartCurveType
    
    init(selectedCurve: Binding<ChartCurveType>) {
        self._selectedCurve = selectedCurve
        self.curve = selectedCurve.wrappedValue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Color.main
                    .frame(width: 6, height: 16)
                    .cornerRadius(8)
                Menu {
                    ForEach(ChartCurveType.allCases, id: \.text) { type in
                        Button {
                            switch type {
                            case .district:
                                curve = .district(startTime: startTime, endTime: endTime)
                            case .combined:
                                curve = .combined(startTime: startTime, endTime: endTime)
                            case .districtAndCombined:
                                curve = .districtAndCombined(startTime: startTime, endTime: endTime)
                            }
                        } label: {
                            Text(type.text)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedCurve.text)
                            .customText(size: 14, color: .text.gray3)
                        Image.main.arrowIconDown
                    }
                }
                Spacer()
            }
            Spacer().frame(height: 20)
            Button {
                startTimePickerShown = true
            } label: {
                HStack {
                    Image.main.calendarIcon
                    Text(startTime ?? "开始日期")
                        .customText(size: 14, color: startTime == nil ? .text.grayCD : .text.gray3)
                }
                .padding(7)
                .frame(width: 119)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.hex("#F2F2F2"), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alwaysPopover(isPresented: $startTimePickerShown) {
                YearMonthPicker(dateString: $startTime, shown: $startTimePickerShown)
            }
            Spacer().frame(height: 10)
            Button {
                endTimePickerShown = true
            } label: {
                HStack {
                    Image.main.calendarIcon
                    Text(endTime ?? "结束日期")
                        .customText(size: 14, color: endTime == nil ? .text.grayCD : .text.gray3)
                }
                .padding(7)
                .frame(width: 119)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.hex("#F2F2F2"), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alwaysPopover(isPresented: $endTimePickerShown) {
                YearMonthPicker(dateString: $endTime, shown: $endTimePickerShown)
            }
        }
        .padding(20)
        .frame(width: 232)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 10)
        .onDisappear {
            print("disappear")
            selectedCurve = curve.filled(startTime: startTime, endTime: endTime)
        }
        .onAppear {
            (startTime, endTime) = selectedCurve.time
        }
    }
}

#Preview("ChartChoises") {
    ChartChoisesView(selectedCurve: .constant(.combined(startTime: nil, endTime: nil)))
}

private struct YearMonthPicker: View {
    @Binding var dateString: String?
    @Binding var shown: Bool
    
    @State private var year: String
    
    private let months = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
    
    private let orgYear: String
    private let orgMonth: Int
    
    init(dateString: Binding<String?>, shown: Binding<Bool>) {
        self._dateString = dateString
        self._shown = shown
        
        if let date = dateString.wrappedValue?.toDate(format: "YYYY-MM") {
            self.orgYear = date.toString(format: "YYYY")
            self.year = date.toString(format: "YYYY")
            
            let month = date.toString(format: "MM")
            self.orgMonth = Int(month) ?? 0
        } else {
            self.year = Date().toString(format: "YYYY")
            self.orgYear = ""
            self.orgMonth = 0
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image.main.arrowIcon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        guard var y = Int(year) else { return }
                        y -= 1
                        y = max(1000, y)
                        year = "\(y)"
                    }
                TextField("", text: $year)
                    .customText(size: 16, color: .text.gray3)
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                Image.main.arrowIcon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: 180))
                    .onTapGesture {
                        guard var y = Int(year) else { return }
                        y += 1
                        y = min(3000, y)
                        year = "\(y)"
                    }
            }
            VStack(spacing: 0) {
                ForEach(1...3, id: \.self) { row in
                    HStack {
                        ForEach((row-1)*4+1...row*4, id: \.self) { i in
                            Button {
                                dateString = "\(year)-\(String(format: "%02d", i))"
                                shown = false
                            } label: {
                                Text(months[i-1])
                                    .customText(size: 16, color: textColor(month: i))
                                    .frame(width: 60, height: 60)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
    
    private func textColor(month: Int) -> Color {
        guard year == orgYear else { return .text.gray3 }
        return month == orgMonth ? .main : .text.gray3
    }
}

#Preview("YearMonthPicker") {
    YearMonthPicker(dateString: .constant("2016-01"), shown: .constant(false))
}
