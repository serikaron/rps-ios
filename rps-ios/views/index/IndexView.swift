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
    @EnvironmentObject var estateService: EstateService
    
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
                            (noticeList, _, _) = await Notice.list(pageNum: 1, pageSize: 3, orgId: accountService.account?.orgId ?? 0)
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
        .onChange(of: accountService.account) { _ in
            Task {
                curves = await chartCurveType.getCurve(unitId: accountService.account?.unitId ?? 0, estateType: estateType.dictKey)
            }
        }
        .onAppear {
            Task {
                curves = await chartCurveType.getCurve(unitId: accountService.account?.unitId ?? 0, estateType: estateType.dictKey)
            }
        }
        .showTabBar()
    }
    
    var content: some View {
        ZStack {
            Color.view.background
            VStack(alignment: .center, spacing: 0) {
                BannerView()
                    .frame(height: 200)
                    .cornerRadius(8)
                Spacer().frame(height: 10)
                noticeSection
                Spacer().frame(height: 16)
                searchInput1
                Spacer().frame(height: 16)
                actionSection
                Spacer().frame(height: 16)
                chartView
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
        NavigationLink(destination: NoticeListView()) {
            NoticeSection(noticeList: noticeList.map{$0.title})
                .padding(.horizontal, 16)
                .background(Color.white)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 15) {
            HStack {
                OCRButton {
                    actionButtonView1(title: "产证识房", icon: Image.index.ocrLogo)
                }
                Spacer().frame(width: 15)
                NavigationLink {
                    MapSearchView()
                } label: {
                    actionButtonView1(title: "地图找房", icon: Image.index.mapLogo)
                }
            }
            HStack {
                NavigationLink {
                    AddInquiryView(inquiryId: 0, roomDetail: nil, inquiry: nil, record: nil)
                } label: {
                    actionButtonView(title: "人工询价", subTitle: "Appraiser Inquiry", icon: .index.inquiryIcon)
                }
                Spacer().frame(width: 15)
                NavigationLink {
                    AddReportView(inquiryId: nil, recordId: nil, detail: nil)
                } label: {
                    actionButtonView(title: "新建委托", subTitle: "New commission", icon: .index.commissionIcon)
                }
            }
        }
    }
    
    private func actionButtonView(title: String, subTitle: String, icon: Image) -> some View {
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
        .frame(height: 66)
        .frame(maxWidth: .infinity)
        .background(
            Image.index.buttonBg
                .resizable()
        )
    }
    
    private func actionButtonView1(title: String, icon: Image) -> some View {
        VStack(spacing: 0) {
            icon
            Text(title)
                .customText(size: 14, color: .main, weight: .medium)
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(
            Image.index.buttonBg
                .resizable()
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
//    private var searchSection: some View {
//        return VStack(spacing: 0) {
//            searchAction
//            searchResult
//        }
//    }
    
    private var searchAction: some View {
        HStack {
            searchInput
                .padding(.top, 28)
                .padding(.bottom, 28)
            Spacer().frame(width: 18)
            NavigationLink {
                MapSearchView()
            } label: {
                Text("地图找房")
                    .customText(size: 14, color: .white)
                    .frame(width: 84, height: 36)
                    .background(Color.main)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#EDF1FF").opacity(0.5))
        .cornerRadius(8)
        .shadow(color: Color(hex: "#C8C8C8").opacity(0.25), radius: 10)
    }
    
    private var searchInput: some View {
        return NavigationLink {
            FuzzySearchView()
        } label: {
            HStack(spacing: 0) {
                OCRButton() {
                    Image.index.searchOCR
                }
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
    
    private var searchInput1: some View {
        NavigationLink {
            FuzzySearchView()
        } label: {
            HStack(spacing: 10) {
                Text("请输入物业名称或地址")
                    .customText(size: 14, color: .text.grayCD)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer().frame(width: 10)
                Image.main.searchIcon
                    .renderingMode(.template)
                    .foregroundColor(.main)
            }
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay (
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.main, lineWidth: 1)
            )
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
    
    private var chartView: some View {
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
        .environmentObject(EstateService.preview)
        .environmentObject(TabService())
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
    @EnvironmentObject private var imageService: ImageService

    @State private var selected: Int = 0
    @State private var banners: [Banner] = []
    
    private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    private var bannerURLs: [URL] {
        banners.compactMap { URL(string: $0.ossUrl) }
    }
    
    var body: some View {
        TabView(selection: $selected) {
            if bannerURLs.isEmpty {
                Image.main.placeholder
            } else {
                ForEach(bannerURLs.indices, id: \.self) { idx in
//                    BackportAsyncImage(url: bannerURLs[idx]) { image in
//                        image.resizable()
//                            .scaledToFill()
//                            .clipped()
//                    } placeholder: {
//                        Image.main.placeholder
//                    }
                    imageService.image(of: bannerURLs[idx])
                        .resizable()
                        .scaledToFill()
                    .tag(idx)
                }
            }
        }
        .tabViewStyle(.page)
        .onAppear(perform: {
            Task {
                banners = await Banner.list
            }
            print(UIDevice.current.identifierForVendor?.uuidString)
        })
        .onReceive(timer, perform: { _ in
            guard bannerURLs.count > 0 else { return }
            withAnimation(.linear(duration: 0.5)) {
                selected = (selected + 1) % bannerURLs.count
            }
        })
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
            YearMonthButton(placeholder: "开始日期", isShown: $startTimePickerShown, time: $startTime)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer().frame(height: 10)
            YearMonthButton(placeholder: "结束日期", isShown: $endTimePickerShown, time: $endTime)
            .frame(maxWidth: .infinity, alignment: .leading)
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

//#Preview("ChartChoises") {
//    ChartChoisesView(selectedCurve: .constant(.combined(startTime: nil, endTime: nil)))
//}

private struct NoticeSection: View {
    let noticeList: [String]
    @State private var curr = 0
    private var next: Int {
        (curr+1) % noticeList.count
    }
    
    private let timer = Timer.publish(every: 2+Self.duration, on: .main, in: .common).autoconnect()
    
    static private let duration: Double = 0.15
    static private let height:CGFloat = 38
    
    var body: some View {
        Group {
            if noticeList.count == 1 {
                oneNotice
            } else if noticeList.count > 1 {
                moreNotice
            } else {
                Image.index.announceIcon
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: Self.height)
    }
    
    private var oneNotice: some View {
        HStack(spacing: 10) {
            Image.index.announceIcon
            textView(noticeList[0])
        }
    }
    
    private var moreNotice: some View {
        HStack(spacing: 10) {
            Image.index.announceIcon
            vTab
        }
        .frame(height: Self.height)
        .clipped()
    }
    
    @State private var offset: CGFloat = Self.height / 2
    
    private var vTab: some View {
        VStack(spacing:0) {
            textView(noticeList[curr])
            textView(noticeList[next])
        }
        .offset(y: offset)
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: Self.duration)) {
                offset -= Self.height
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+Self.duration) {
                curr = next
                offset = Self.height / 2
            }
        }
    }
    
    private func textView(_ text: String) -> some View {
        Text(text)
            .frame(height: Self.height)
            .customText(size: 14, color: .text.gray3)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Notice") {
    NoticeSection(noticeList: [])
}
