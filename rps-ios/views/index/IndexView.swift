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
    var body: some View {
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
    
    @State private var selectedTab: ChartTab = .apartment
    private var searchResult: some View {
        VStack {
            ChartTabView(selected: $selectedTab)
            ChartView()
            HStack {
                HStack {
                    Image.index.pointIcon
                    Text("价格走势")
                        .customText(size: 14, color: .text.gray3)
                }
                Spacer()
                HStack {
                    Image.index.editIcon
                    Text("编辑指标")
                        .customText(size: 14, color: .main)
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

private enum ChartTab: CaseIterable {
    case apartment, office, villa, store
    
    var text: String {
        switch self {
        case .apartment: return "普通公寓"
        case .office: return "写字楼"
        case .villa: return "排屋别墅"
        case .store: return "沿街商铺"
        }
    }
}

private struct ChartTabView: View {
    @Binding var selected: ChartTab
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 35) {
                ForEach(ChartTab.allCases, id: \.hashValue) { tab in
                    if tab == selected {
                        VStack {
                            Text(tab.text).customText(size: 14, color: .main)
                            Color.main.frame(width: 20, height: 3)
                        }
                    } else {
                        VStack {
                            Text(tab.text).customText(size: 14, color: .text.gray3)
                            Spacer()
                        }
                    }
                }
            }
//            .padding(.horizontal, 16)
            .frame(height: 30)
        }
    }
}

private struct ChartView: UIViewRepresentable {
    func makeUIView(context: Context) -> DGCharts.LineChartView {
        let chart = LineChartView()
        let data = LineChartData()
        let dataSet = LineChartDataSet(entries: [
            ChartDataEntry(x: 1, y: 1),
            ChartDataEntry(x: 2, y: 2),
            ChartDataEntry(x: 3, y: 1),
            ChartDataEntry(x: 4, y: 2),
        ], label: "abc")
        dataSet.mode = .cubicBezier
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        let colors = [Color.main.cgColor, Color.main.opacity(0).cgColor] as CFArray
        let locations:[CGFloat] = [1.0, 0.0]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)
        if gradient == nil {
            dataSet.fill = ColorFill(color: .magenta)
        } else {
            dataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90)
        }
        dataSet.drawFilledEnabled = true
        dataSet.colors = [Color.main.uiColor]
        data.dataSets = [dataSet]
        chart.data = data
        chart.leftAxis.drawLabelsEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.axisLineDashLengths = [5, 5, 0]
        chart.rightAxis.enabled = false
        chart.xAxis.drawAxisLineEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelCount = dataSet.count-1
        chart.xAxis.gridLineDashLengths = [5, 5, 0]
        chart.legend.enabled = false
        return chart
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    typealias UIViewType = LineChartView
}

#Preview {
    IndexView()
        .environmentObject(AccountService())
//    ChartView()
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

#Preview("banner") {
    BannerView()
}
