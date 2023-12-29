//
//  RoomDetailView.swift
//  rps-ios
//
//  Created by serika on 2023/11/13.
//

import SwiftUI
import SBPAsyncImage

struct RoomDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var accountService: AccountService
    @EnvironmentObject var tabService: TabService
    
    private var account: Account? { accountService.account }
    
    
    let familyRoomName: String
    let areaCode: Int
    let estateType: String
    let buildingId: Int
    let area: String
    @State var floor: String
    var roomId: String { roomDetail.id }
    
    @State private var inquiry: Inquiry?
    @State private var roomDetail: RoomDetail = .empty
    
    @State private var initialized: Bool = false
    @State private var hasInquiryResult: Bool = false
    @State private var detailExtened: Bool = false
    @State private var hasDetailResult: Bool = false
    @State private var isInfoFixShown: Bool = false
    
    var body: some View {
        ZStack {
            Color.view.background
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .ignoresSafeArea(edges: .bottom)
            VStack(spacing: 0) {
                ScrollView {
                    ZStack(alignment: .top) {
                        BannerView(roomDetail: $roomDetail)
                            .frame(height: 252)
                            .frame(maxHeight: .infinity, alignment: .top)
                        VStack(spacing: 10) {
                            Spacer().frame(height: 219)
                            upperView
                            Spacer().frame(height: 20)
                        }
                    }
                }
                if selectedTab == .inquiryDetail {
                    OverlayView(
                        inquiry: $inquiry,
                        hasInquiryResult: $hasInquiryResult,
                        detailExtened: $detailExtened,
                        hasDetailResult: $hasDetailResult
                    )
                }
            }
            if isInfoFixShown {
                InfoFixView(inquiry: $inquiry, roomDetail: $roomDetail, buildingFloor: $floor, isInfoFixShown: $isInfoFixShown)
            }
        }
        .setupNavigationBar(title: "系统询价详情") {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            Task {
                guard !initialized else { return }
                
                roomDetail = await estateService.getRoomDetail(
                    estateType: estateType,
                    areaCode: areaCode,
                    familyRoomName: familyRoomName,
                    buildingId: buildingId,
                    orgId: accountService.account?.orgId ?? 0
                )
                inquiry = await estateService.createInquiry(buildingId: buildingId, estateType: estateType, areaCode: areaCode, searchAddr: familyRoomName, orgId: accountService.account?.orgId ?? 0, roomId: Int(roomId) ?? 0)
                if !area.isEmpty {
                    inquiry?.area = Double(area) ?? 0
                }
                initialized = true
            }
            selectedTab = accountService.account?.firstTab
        }
        .showTabBar()
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    @State private var selectedTab: RoomDetailTab?
    
    private var upperView: some View {
        VStack(spacing: 0) {
            if hasInquiryResult {
                HStack(spacing: 20) {
                    Text("单价：\(inquiry?.price ?? "")元/m²")
                        .customText(size: 16, color: .text.gray6, weight: .medium)
                    Text("总价：\(inquiry?.totalPrice ?? "")元")
                        .customText(size: 16, color: .text.gray6, weight: .medium)
                    Spacer()
                }
                .padding(.horizontal, 16)
                Spacer().frame(height: 17)
            }
            Text(roomDetail.roomName)
                .customText(size: 18, color: .text.gray3, weight: .medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            Spacer().frame(height: 17)
            RoomDetailTabView(selectedTab: $selectedTab)
            Color.hex("#CDCDCD")
                .frame(height: 1)
            Spacer().frame(height: 16)
            tabContent
        }
        .sectionStyle()
    }
    
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .inquiryDetail:
                inquiryDetailPage.earseToAnyView()
            case .reference:
                ReferenceCaseView(inquiry: inquiry, detail: roomDetail).earseToAnyView()
            case .chart:
                ChartPage(inquiry: $inquiry, roomDetail: $roomDetail)
            case .estateDetail:
                EstateDetailView(detail: $roomDetail)
            case .none:
                EmptyView()
            }
        }
    }
    
    private var inquiryDetailPage: some View {
        VStack {
            RoomInfoView(
                floor: floor, roomDetail: roomDetail,
                isInfoFixShown: $isInfoFixShown, hasDetailResult: $hasDetailResult
            )
            if account?.canShowMapView ?? false {
                mapView
            }
            if inquiry?.estateType == .industrialFactory {
                LandListView(inquiry: $inquiry)
                BuildListView(inquiry: $inquiry)
                if hasInquiryResult {
                    ResultView(inquiry: inquiry!, detailExtened: $detailExtened)
                    if !hasDetailResult {
                        actionView
                    }
                }
            } else {
                if hasInquiryResult {
                    ResultView(inquiry: inquiry!, detailExtened: $detailExtened)
                    if !hasDetailResult {
                        actionView
                    }
                }
            }
            if detailExtened {
                if account?.canShowDecorateView ?? false {
                    DecorateView(inquiry: $inquiry)
                }
                if account?.canShowAuxiliaryView ?? false {
                    AuxiliaryRoomListView(inquiry: $inquiry)
                }
                if account?.cahShowAdjustView ?? false {
                    ResultAdjustView(inquiry: $inquiry)
                }
            }
            if hasDetailResult {
                DetailResultView(inquiry: $inquiry)
                actionView
            }
        }
    }
    
    @State private var mapShowing: Bool = true
    private var mapView: some View {
        VStack {
            Button {
                mapShowing.toggle()
            } label: {
                HStack(spacing: 0) {
                    Text("地图定位")
                        .customText(size: 16, color: .text.gray3, weight: .medium)
                    Image.index.mapIcon
                        .rotationEffect(mapShowing ? .degrees(180) : .zero)
                    Spacer()
                }
            }
            Spacer().frame(height: 16)
            if mapShowing {
//                MapView(coordinate: $roomDetail.coordinate)
                MapView(mapViewCoordinate: roomDetail.mapViewCoordinate)
                    .frame(height: 138)
                    .cornerRadius(5)
            }
        }
        .sectionStyle()
    }
    
    private func resultItem(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .customText(size: 14, color: .text.gray6)
            Spacer()
            Text(value)
                .customText(size: 14, color: .text.gray6)
        }
    }
    
    private var actionView: some View {
        VStack(spacing: 20) {
            HStack {
                NavigationLink {
                    ReportSheetView(type: InquiryType.system.dictKey, estateType: estateType, inquiryId: inquiry?.id ?? 0, reportState: 2)
                } label: {
                    actionItem(title: "获取报告单")
                }
                Spacer()
                NavigationLink {
                    AddInquiryView(inquiry: inquiry, record: nil)
                } label: {
                    actionItem(title: "估价师询价")
                }
//                Spacer()

            }
            HStack {
//                actionItem(title: "价格反馈")
//                    .onTapGesture {
//                        tabService.selectedTab = .cs
//                    }
//                Spacer()
                NavigationLink {
                    AddReportView(inquiry: inquiry, detail: roomDetail)
                } label: {
                    actionItem(title: "委托报告")
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = copyText
                    Box.sendError("已复制到剪贴板")
                } label: {
                    actionItem(title: "复制询价")
                }
//                Spacer()
//                actionItem(title: "历史信息")
            }
        }
        .sectionStyle()
    }
    
    private var copyText: String {
"""
地址:\(roomDetail.roomName)
面积:\(inquiry?.area ?? 0)(㎡)
房产总价:\(inquiry?.totalPrice ?? "")
询价人:\(inquiry?.contact ?? "")
询价时间:\(inquiry?.valuationDate ?? "")
"""
    }
    
    private func actionItem(title: String) -> some View {
        Text(title)
            .customText(size: 14, color: .main)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .overlay (
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.main, lineWidth: 1)
            )
    }
    
}

#Preview {
    MapService.initMAMapKit()
    return TabView {
        NavigationView {
            RoomDetailView(
                familyRoomName: "宝石1幢1单元RF301",
                areaCode: 300106,
                estateType: "singleApartment",
                buildingId: 1,
                area: "",
                floor: "1-1"
            )
            .environmentObject(
                EstateService()
            )
            .environmentObject(AccountService.preview)
            .environmentObject(TabService())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
//
//#Preview("online") {
//    Box.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJycHNfdXNlcjo0MCIsInJuU3RyIjoiR3Uza1VDRlp0WENiUnNQbnZFbzR6bHdSbmdQNXFQQmoiLCJ1c2VySWQiOjQwfQ.vWHDeE0OHg2ldyTlnCDSFN9p67IoqQyU1jhzZncRIEo")
//    Task {
//        await DictType.getDict()
//    }
//    return NavigationView {
//        RoomDetailView(
//            familyRoomName: "路段1号101",
//            areaCode: 300106,
//            estateType: "shopStreet",
//            buildingId: 1,
//            floor: "1-1"
//        )
//        .environmentObject( EstateService() )
//        .environmentObject(AccountService())
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

private enum RoomDetailTab: CaseIterable {
    case inquiryDetail, reference, chart, estateDetail
    
    var title: String {
        switch self {
        case .inquiryDetail: return "估价详情"
        case .reference: return "参考案例"
        case .chart: return "价格走势"
        case .estateDetail: return "房产详情"
        }
    }
}

private struct RoomDetailTabView: View {
    @EnvironmentObject var accountService: AccountService
    @Binding var selectedTab: RoomDetailTab?
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(accountService.account?.roomDetailTabs ?? [], id: \.hashValue) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack {
                        if selectedTab == tab {
                            Text(tab.title).customText(size: 16, color: .main, weight: .medium)
                            Color.main.frame(width: 20, height: 3)
                        } else {
                            Text(tab.title).customText(size: 16, color: .hex("#CDCDCD"), weight: .medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

//#Preview("tab view") {
//    RoomDetailTabView(selectedTab: .constant(.chart))
//        .environmentObject(AccountService.preview)
//}

private struct RoomInfoView: View {
    let floor: String
    
    let roomDetail: RoomDetail
    private var estateType: DictType.EstateType? { roomDetail.estateType }
//    private var estateType: EstateType? { EstateType.shopStreet }
    
    @Binding var isInfoFixShown: Bool
    @Binding var hasDetailResult: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("基本信息")
                    .customText(size: 16, color: .text.gray3, weight: .medium)
                Spacer()
                if !hasDetailResult {
                    Text("基本信息纠错")
                        .customText(size: 14, color: .white)
                        .frame(height: 30)
                        .padding(.horizontal, 10)
                        .background(Color.main)
                        .cornerRadius(15)
                        .onTapGesture {
                            isInfoFixShown = true
                        }
                }
            }
            Spacer().frame(height: 17)
            HStack {
                Text("产权地址")
                    .customText(size: 14, color: .text.gray6)
                Text(roomDetail.address)
                    .customText(size: 14, color: .text.gray3)
                Spacer()
            }
            Spacer().frame(height: 15)
            VStack(spacing: 10) {
                ForEach(Array(zip(itemToShow.indices, itemToShow)), id: \.0) { _, row in
                    HStack(spacing:0) {
                        ForEach(Array(zip(row.indices, row)), id: \.0) { idx, item in
                            if (idx != 0) { divider }
                            itemView(title: title(for: item), content: value(for: item))
                            if idx == row.count - 1 &&
                                row.count != 4 {
                                Spacer().earseToAnyView()
                            }
                        }
                    }
                    .frame(width: 320)
                }
            }
        }
    }
    
    private var divider: some View {
        Color.view.background
            .frame(width: 1, height: 54)
    }
    
    private func itemView(title: String, content: String) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .customText(size: 14, color: .text.gray6)
            Text(content)
                .customText(size: 14, color: .text.gray3)
        }
        .frame(width: 80)
//        .frame(maxWidth: .infinity)
    }
    
    private func title(for item: RoomInfoItem) -> String {
        switch item {
        case .estateType:
            switch estateType {
            case .villa: return "房产分类"
            case .shopStreet: return "商业类型"
            default: return "物业类型"
            }
        case .landUser: return "使用权类型"
        case .completionDate: return "建成年份"
        case .position: return "所在部位"
        case .structure: return "建筑结构"
        case .landLevel: return "土地等级"
        case .facing: return "建筑朝向"
        case .height: return "地上总层"
        case .floor: return "所在楼层"
        case .landingroomUsage: return "土地用途"
        case .property: return "房屋性质"
        case .usage: return "房屋用途"
        }
    }
    
    private func value(for item: RoomInfoItem) -> String {
        switch item {
        case .estateType: return roomDetail.estateTypeText
        case .landUser: return roomDetail.landUser?.label ?? nilText
        case .completionDate: return roomDetail.completionDate
        case .position: return roomDetail.position
        case .structure: return roomDetail.structure
        case .landLevel: return roomDetail.landLevel
        case .facing: return roomDetail.facing
        case .height: return roomDetail.height
        case .floor: return roomDetail.floor ?? floor
        case .landingroomUsage: return roomDetail.landingroomUsage
        case .property: return roomDetail.property
        case .usage: return roomDetail.usage
        }
    }
    
    private var itemToShow: [[RoomInfoItem]] {
//        print("itemToShow, estateType: \(estateType)")
        switch estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .industrialSmallGarden:
            return [
                [.estateType, .landUser, .property, .usage],
                [.structure, .facing, .completionDate, .position],
                [.height, .floor]
            ]
        case .landingRoom:
            return [
                [.estateType, .landUser, .landingroomUsage, .usage],
                [.structure, .facing, .completionDate, .position],
                [.height, .floor]
            ]
        case .shopStreet:
            return [
                [.estateType, .landLevel, .property, .usage],
                [.structure, .facing, .completionDate, .position],
                [.height, .floor]
            ]
        case .industrialFactory:
            return [[.estateType]]
        case nil:
            return [[]]
//            return [
//                [.estateType, .landUser, .property, .usage],
//                [.structure, .facing, .completionDate, .position],
//                [.height, .floor]
//            ]
        }
    }
    
    private let nilText = "无"
}

private struct OverlayView: View {
    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var accountService: AccountService
    
    @Binding var inquiry: Inquiry?
    @Binding var hasInquiryResult: Bool
    @Binding var detailExtened: Bool
    @Binding var hasDetailResult: Bool
    
    var body: some View {
        VStack {
            if canShowInquiry {
                inquiryView
            }
            if canShowExtendButton &&
                accountService.account?.canExtendDetail ?? false
            {
                extendButton
            }
            if canShowDetailButton {
                detailButton
            }
        }
        .padding(.horizontal, 12)
    }
    
    private var canShowInquiry: Bool {
        !detailExtened
    }
    
    private var areaText: Binding<String> {Binding(
        get: { inquiry?.areaString ?? "" },
        set: { inquiry?.areaString = $0 }
    )}
    
    private var inquiryView: some View {
        HStack {
            TextField("请输入建筑面积", text: areaText)
                .keyboardType(.numberPad)
            Text("估一下")
                .customText(size: 14, color: .white)
                .frame(width: 81, height: 36)
                .background(Color.hex("#FFB23F"))
                .cornerRadius(8)
                .onTapGesture {
                    Task {
                        guard let inquiry = inquiry else { return }
                        self.inquiry = await estateService.inquire(inquiry: inquiry)
                        hasInquiryResult = true
                    }
                }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private var canShowExtendButton: Bool {
        hasInquiryResult && !detailExtened
    }
    
    private var extendButton: some View {
        Button {
            detailExtened = true
        } label: {
            Text("展开详细估价")
                .customText(size: 16, color: .white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.main)
                .cornerRadius(8)
        }
    }
    
    private var canShowDetailButton: Bool {
        hasInquiryResult && detailExtened
    }
    
    private var detailButton: some View {
        Button {
            Task {
                guard let inquiry = inquiry else { return }
                self.inquiry = await estateService.inquireDetail(inquiry: inquiry)
                hasDetailResult = true
            }
        } label: {
            Text("详细估价")
                .customText(size: 16, color: .white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.main)
                .cornerRadius(8)
        }
    }
}

//#Preview("Overlay") {
//    VStack {
//        Text("估一下")
//        OverlayView(
//            inquiry: .constant(.empty),
//            hasInquiryResult: .constant(false),
//            detailExtened: .constant(false),
//            hasDetailResult: .constant(true)
//        )
//        Text("估一下 + 展开")
//        OverlayView(
//            inquiry: .constant(.empty),
//            hasInquiryResult: .constant(true),
//            detailExtened: .constant(false),
//            hasDetailResult: .constant(true)
//        )
//        Text("详细估价")
//        OverlayView(
//            inquiry: .constant(.empty),
//            hasInquiryResult: .constant(true),
//            detailExtened: .constant(false),
//            hasDetailResult: .constant(true)
//        )
//    }
//    .background(Color.gray)
//}

private enum RoomInfoItem {
    case estateType, landUser, completionDate, position, structure, facing, height, floor, landLevel, usage, property, landingroomUsage
}

private struct ResultView: View {
    let inquiry: Inquiry
    @Binding var detailExtened: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text("估价结果").headerText()
            Spacer().frame(height: 20)
            VStack(spacing: 10) {
                if inquiry.estateType == .industrialFactory {
                    ListItem(title: "土地总价", content: "\(inquiry.landTotalPrice ?? "0")元")
                    ListItem(title: "建筑物总价", content: "\(inquiry.buildTotalPrice ?? "0")元")
                }
                ListItem(title: "房产评估单价", content: "\(inquiry.price)元/m²")
                ListItem(title: "房产评估总价", content: "\(inquiry.totalPrice)元")
                ListItem(title: "估价时间", content: "\(inquiry.date)")
                ForEach(Array(zip(inquiry.otherPriceInfos.indices, inquiry.otherPriceInfos)), id: \.0) { _, info in
                    ListItem(title: (info.name ?? "") + "单价", content: "\(info.price ?? "0")")
                    ListItem(title: (info.name ?? "") + "总价", content: "\(info.totalPrice ?? "0")")
                }
            }
            if detailExtened {
                Divider()
                Button {
                    detailExtened = false
                } label: {
                    Text("收起详细估价")
                        .customText(size: 14, color: .main)
                        .frame(height: 36)
                }
            }
        }
        .sectionStyle()
    }
}

#Preview("ResultView") {
    ResultView(inquiry: Inquiry(networkInquiry: [
        "fvOtherPriceInfo": "[{\"name\":\"额外金额2\",\"price\":\"1010\",\"totalPrice\":\"101000\"},{\"name\":\"额外金额\",\"price\":\"1010\",\"totalPrice\":\"101000\"}]"
    ]), detailExtened: .constant(true))
}

private struct DecorateView: View {
    @Binding var inquiry: Inquiry?
    
    var body: some View {
        VStack {
            Text("室内因素")
                .headerText()
            Spacer().frame(height: 20)
            planeShapePicker
            Divider()
            levelDecoratePicker
//            Divider()
//            decorateDatePicker
        }
        .sectionStyle()
    }
    
    private var planeShapePicker: some View {
        FlexibleListItem(title: "户型布局") {
            Menu {
                ForEach(DictType.PlaneShape.allCases, id: \.self) { shape in
                    Button {
                        inquiry?.style = shape
                    } label: {
                        Text(shape.label)
                    }
                }
            } label: {
                HStack {
                    Text(inquiry?.style?.label ?? "请选择户型布局")
                    Image.main.arrowIconRight
                }
            }
        }
    }
    
    private var levelDecoratePicker: some View {
        FlexibleListItem(title: "装修情况") {
            Menu {
                ForEach(DictType.LevelDecorate.allCases, id: \.self) { deco in
                    Button {
                        inquiry?.decoration = deco
                    } label: {
                        Text(deco.label)
                    }
                }
            } label: {
                HStack {
                    Text(inquiry?.decoration?.label ?? "请选择装修情况")
                    Image.main.arrowIconRight
                }
            }
        }
    }
    
    private var date: Binding<Date> {Binding(
        get: { inquiry?.decorationDate?.toDate() ?? Date() },
        set: { inquiry?.decorationDate = $0.toString() }
    )}
    private var decorateDatePicker: some View {
        FlexibleListItem(title: "装修时间") {
            HStack {
                Text(inquiry?.decorationDate ?? "选择装修时间")
                Image.main.arrowIconRight
            }
        }
        .overlay (
            DatePicker("date", selection: date, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(.compact)
                .blendMode(.destinationOver)
        )
    }
}

//#Preview("DecorateView") {
//    PreviewView {
//        DecorateView(inquiry: $0)
//            .background(Color.view.background)
//    }
//}

private struct AuxiliaryRoomListView: View {
    
    @Binding var inquiry: Inquiry?
    
    private var roomList: [AuxiliaryRoom] {
        var out: [AuxiliaryRoom] = [.fixedRoom(with: inquiry?.area == nil ? "" : "\(inquiry!.area!)")]
        if inquiry != nil {
            out += inquiry!.auxiliaryRoomList
        }
        return out
    }
    
    var body: some View {
        switch inquiry?.estateType {
        case .landingRoom:
            fallthrough
        case .shopStreet:
            fallthrough
        case .none:
            return EmptyView().earseToAnyView()
        default:
            return content.earseToAnyView()
        }
    }
    
    private var content: some View {
        VStack {
            Text("辅房及附属物")
                .headerText()
            Spacer().frame(height: 20)
            ForEach(Array(zip(roomList.indices, roomList)), id: \.0) { idx, room in
                itemView(for: room, idx: idx, canRmove: idx != 0)
                divider
            }
            NavigationLink {
                AuxiliaryRoomCreateView(inquiry: $inquiry)
            } label: {
                HStack {
                    Image.index.addIcon
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("新增辅房及附属物")
                        .customText(size: 14, color: .text.gray3)
                }
                .frame(height: 36)
            }
        }
        .sectionStyle()
    }
    
    private func itemView(for room: AuxiliaryRoom, idx: Int, canRmove: Bool) -> some View {
        FlexibleListItem(title: room.propertyAttribute?.label ?? "") {
            if (canRmove) {
                Image.index.removeIcon
                    .onTapGesture {
                        inquiry?.removeAuxiliaryRoom(at: idx - 1)
                    }
                Spacer().frame(width: 12)
            }
            NavigationLink {
                AuxiliaryRoomInfoView(room: room)
            } label: {
                Text("查看详情")
                    .customText(size: 14, color: .main)
            }
        }
    }
    
    private var divider: some View {
        Color.view.background
            .frame(height: 1)
    }
}

//#Preview("AuxiliaryRoomListView") {
//    var inquiry = Inquiry.empty
//    return PreviewView(inquiry: inquiry.setEstateType(.commApartment)) { inquiry in
//        AuxiliaryRoomListView(inquiry: inquiry)
//    }
//}

private struct AuxiliaryRoomInfoView: View {
    let room: AuxiliaryRoom
    
    var body: some View {
        VStack(spacing: 0) {
            ListItem(title: "物业类型", content: room.propertyAttribute?.label ?? "")
            Divider()
            ListItem(title: "物业名称", content: room.name)
            Divider()
            ListItem(title: "有无产权", content: room.commonHas?.label ?? "")
            Divider()
            ListItem(title: "计算面积", content: room.area ?? "")
        }
        .sectionStyle()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.view.background)
    }
    
}

//#Preview("AuxiliaryRoomView") {
//    AuxiliaryRoomInfoView(room: AuxiliaryRoom(propertyAttribute: .auxiliaryHouse(subType: .attic), commonHas: .not, unit: "m", area: 200))
//        .background(Color.black)
//}

private struct AuxiliaryRoomCreateView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var inquiry: Inquiry?
    
    @State private var newRoom: AuxiliaryRoom = .new()
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                propertyPickerView
                Divider()
                namePickerView
                Divider()
                hasPickerView
                Divider()
                areaInputView
            }
            .sectionStyle()
            Spacer()
            Text("保存")
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .customText(size: 14, color: .white)
                .background(Color.main)
                .cornerRadius(8)
                .padding(.horizontal, 12)
                .onTapGesture {
                    switch newRoom.propertyAttribute {
                    case .mainHouse: break
                    case .auxiliaryHouse(let subType):
                        guard subType != nil else { return }
                    case .appendages(let subType):
                        guard subType != nil else { return }
                    default:
                        return
                    }
                    
                    guard newRoom.area != nil,
                          newRoom.commonHas != nil
                    else { return }
                    
                    newRoom.unit = "m"
                    inquiry?.addAuxiliaryRoom(newRoom)
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .background(Color.view.background)
    }
    
    private var propertyList: [DictType.PropertyAttribute] {
        [.mainHouse, .auxiliaryHouse(subType: nil), .appendages(subType: nil)]
    }
    
    private var propertyPickerView: some View {
        FlexibleListItem(title: "物业类型") {
            Menu {
                ForEach(Array(zip(propertyList.indices, propertyList)), id: \.0) { _, property in
                    Button {
                        newRoom.propertyAttribute = property
                    } label: {
                        Text(property.label)
                            .itemContent()
                    }
                }
            } label: {
                label(newRoom.propertyAttribute?.label)
            }
        }
    }
    
    private var namePickerView: some View {
        FlexibleListItem(title: "物业名称") {
            switch newRoom.propertyAttribute {
            case .mainHouse:
                label(DictType.MainHouse.mian.label)
            case .auxiliaryHouse(let subType):
                Menu {
                    ForEach(DictType.AuxiliaryHouse.allCases, id: \.self) { subType in
                        Button {
                            newRoom.propertyAttribute = .auxiliaryHouse(subType: subType)
                        } label: {
                            Text(subType.label)
                        }
                    }
                } label: {
                    label(subType?.label)
                }
            case .appendages(let subType):
                Menu {
                    ForEach(DictType.Appendages.allCases, id: \.self) { subType in
                        Button {
                            newRoom.propertyAttribute = .appendages(subType: subType)
                        } label: {
                            Text(subType.label)
                        }
                    }
                } label: {
                    label(subType?.label)
                }
            default:
                label("请选择")
            }
        }
    }
    
    private var hasPickerView: some View {
        FlexibleListItem(title: "有无产权") {
            Menu {
                ForEach(DictType.CommonHas.allCases, id: \.self) { v in
                    Button {
                        newRoom.commonHas = v
                    } label: {
                        Text(v.label)
                    }
                }
            } label: {
                label(newRoom.commonHas?.label)
            }
        }
    }
    
    private var areaText: Binding<String> { Binding(
        get: { newRoom.area ?? "" },
        set: { newRoom.area = $0 }
    )}
    
    private var areaInputView: some View {
        FlexibleListItem(title: "面积（数量)") {
            HStack {
                Spacer()
                TextField("", text: areaText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                Text(newRoom.unit ?? "")
            }
        }
    }
    
    private func label(_ title: String?) -> some View {
        HStack {
            Text(title ?? "请选择")
            Image.main.arrowIconRight
        }
    }
}

//#Preview("AuxiliaryRoomCreateView") {
//    AuxiliaryRoomCreateView(inquiry: .constant(.empty))
//}

private extension AuxiliaryRoom {
    static func fixedRoom(with area: String) -> AuxiliaryRoom {
        AuxiliaryRoom(
            propertyAttribute: .mainHouse,
            commonHas: .has, unit: "m²",
            area: area
        )
    }
}

private struct ResultAdjustView: View {
    @Binding var inquiry: Inquiry?
    
    private var date: Binding<Date> {Binding(
        get: { inquiry?.date.toDate() ?? Date() },
        set: { inquiry?.date = $0.toString() }
    )}
    private var dateString: String {
        if let date = inquiry?.date,
           !date.isEmpty {
            return date
        } else {
            return "请选择估价时间"
        }
    }
    
    private var fee: Binding<String> {Binding(
        get: { inquiry?.fee ?? "" },
        set: { inquiry?.fee = $0 }
    )}
    
    private var feeRatio: Binding<String> {Binding(
        get: { inquiry?.feeRatio ?? "" },
        set: { inquiry?.feeRatio = $0 }
    )}
    
    var body: some View {
        VStack {
            Text("结果调整").headerText()
            VStack {
                FlexibleListItem(title: "估价时间") {
                    Text(dateString)
                    Image.main.arrowIconRight
                }
                .overlay(
                    DatePicker("date", selection: date, in: ...Date(), displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .blendMode(.destinationOver)
                )
                Divider()
                FlexibleListItem(title: "处置税费金额") {
                    HStack {
                        TextField("", text: fee)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text("元")
                    }
                }
                Divider()
                FlexibleListItem(title: "处置税费比例") {
                    HStack {
                        TextField("", text: feeRatio)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text("%")
                    }
                }
            }
        }
        .sectionStyle()
    }
}

//#Preview("ResultAdjustView") {
//    PreviewView {
//        ResultAdjustView(inquiry: $0)
//    }
//}

private struct DetailResultView: View {
    @Binding var inquiry: Inquiry?
    
    var body: some View {
        VStack {
            Text("详细估价结果").headerText()
            Spacer().frame(height: 20)
            ForEach(items, id: \.self) { item in
                ListItem(title: item.title, content: "\(inquiry?.stringValue(of: item.rawValue) ?? "0")\(item.unit)")
                Divider()
            }
        }
        .sectionStyle()
    }
    
    private var items: [Item] {
        switch inquiry?.estateType {
        case .landingRoom:
            fallthrough
        case .shopStreet:
            return [.fvTotalPriceBeforeAdjustment, .fvUnitPriceBeforeAdjustment, .fvValuationTotalPrice, .fvValuationPrice, .fvNetMortgageValue, .fvValuationDate]
        case nil:
            return []
        default:
            return Item.allCases
        }
    }
    
    private enum Item: String, CaseIterable {
        case fvTotalPriceBeforeAdjustment, fvUnitPriceBeforeAdjustment, fvValuationTotalPrice, fvValuationPrice, fvTotalPriceAuxiliaryRoomsHavePropertyRights, fvTotalPriceAuxiliaryRoomsNoPropertyRights, fvTotalPriceAccessoriesHavePropertyRights, fvTotalPriceAccessoriesNoPropertyRights, fvNetMortgageValue, fvValuationDate
        
        var title: String {
            switch self {
            case .fvTotalPriceBeforeAdjustment:
                return "调整前总价"
            case .fvUnitPriceBeforeAdjustment:
                return "调整前单价"
            case .fvValuationTotalPrice:
                return "房地产评估总价"
            case .fvValuationPrice:
                return "房地产评估单价"
            case .fvTotalPriceAuxiliaryRoomsHavePropertyRights:
                return "辅房总价（有产权）"
            case .fvTotalPriceAuxiliaryRoomsNoPropertyRights:
                return "辅房总价（无产权）"
            case .fvTotalPriceAccessoriesHavePropertyRights:
                return "附属物总价（有产权）"
            case .fvTotalPriceAccessoriesNoPropertyRights:
                return "附属物总价（无产权）"
            case .fvNetMortgageValue:
                return "抵押净值"
            case .fvValuationDate:
                return "估价时间"
            }
        }
        
        var unit: String {
            switch self {
            case .fvTotalPriceBeforeAdjustment:
                return "元/m²"
            case .fvUnitPriceBeforeAdjustment:
                return "元"
            case .fvValuationTotalPrice:
                return "元/m²"
            case .fvValuationPrice:
                return "元"
            case .fvTotalPriceAuxiliaryRoomsHavePropertyRights:
                return "元"
            case .fvTotalPriceAuxiliaryRoomsNoPropertyRights:
                return "元"
            case .fvTotalPriceAccessoriesHavePropertyRights:
                return "元"
            case .fvTotalPriceAccessoriesNoPropertyRights:
                return "元"
            case .fvNetMortgageValue:
                return "元"
            case .fvValuationDate:
                return ""
            }
        }
    }
}

//#Preview("DetailResultView") {
//    PreviewView(inquiry: .init(networkInquiry: ["fvTotalPriceBeforeAdjustment": "123"])) { inquiry, roomDetail in
//        DetailResultView(inquiry: inquiry)
//    }
//}

private struct LandInfoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let land: LandIndustrialFactory
    
    var body: some View {
        VStack {
            ListItem(title: "土地名称", content: land.name ?? "")
            ListItem(title: "土地面积（m²）", content: "\(land.area ?? "")m²")
            ListItem(title: "土地性质", content: land.landUser?.label ?? "")
            ListItem(title: "土地终止日期", content: land.endDate ?? "")
            ListItem(title: "土地用途", content: land.landSe?.label ?? "")
            ListItem(title: "临路状况", content: land.roadCondition?.label ?? "")
        }
        .sectionStyle()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.view.background)
        .setupNavigationBar(title: "土地信息详情") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//#Preview("LandInfo") {
//    LandInfoView(land: LandIndustrialFactory(
//        name: "land",
//        area: 10,
//        landUser: ._1,
//        endDate: "2001",
//        landSe: ._1,
//        roadCondition: ._1
//    ))
//}

private struct LandCreateView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var inquiry: Inquiry?
    
    @State private var newLand = LandIndustrialFactory()
    
    private var name: Binding<String> { Binding(
        get: { newLand.name ?? "" },
        set: { newLand.name = $0 }
    )}
    
    private var area: Binding<String> { Binding(
        get: { newLand.area ?? "" },
        set: { newLand.area = $0 }
    )}
    
    private var date: Binding<Date> { Binding(
        get: { newLand.endDate?.toDate() ?? Date() },
        set: { newLand.endDate = $0.toString() }
    )}
    
    var body: some View {
        VStack {
            VStack {
                FlexibleListItem(title: "土地名称") {
                    TextField("请输入", text: name)
                        .multilineTextAlignment(.trailing)
                }
                FlexibleListItem(title: "土地面积（m²）") {
                    HStack {
                        TextField("请输入", text: name)
                            .multilineTextAlignment(.trailing)
                    }
                    Text("m²")
                }
                FlexibleListItem(title: "土地性质") {
                    Menu {
                        ForEach(DictType.LandUser.allCases, id: \.self) { landUser in
                            Button {
                                newLand.landUser = landUser
                            } label: {
                                Text(landUser.label)
                            }
                        }
                    } label: {
                        HStack {
                            Text(newLand.landUser?.label ?? "请选择")
                            Image.main.arrowIconRight
                        }
                    }
                }
                FlexibleListItem(title: "土地终止日期") {
                    Text(newLand.endDate ?? "请选择日期")
                        .overlay(
                            DatePicker("date", selection: date)
                                .datePickerStyle(.compact)
                                .blendMode(.destinationOver)
                        )
                }
                FlexibleListItem(title: "土地用途") {
                    Menu {
                        ForEach(DictType.LandSe.allCases, id: \.self) { landSe in
                            Button {
                                newLand.landSe = landSe
                            } label: {
                                Text(landSe.label)
                            }
                        }
                    } label: {
                        HStack {
                            Text(newLand.landSe?.label ?? "请选择")
                            Image.main.arrowIconRight
                        }
                    }
                }
                FlexibleListItem(title: "临路状况") {
                    Menu {
                        ForEach(DictType.TemporaryRoadConditions.allCases, id: \.self) { roadCondition in
                            Button {
                                newLand.roadCondition = roadCondition
                            } label: {
                                Text(roadCondition.label)
                            }
                        }
                    } label: {
                        HStack {
                            Text(newLand.roadCondition?.label ?? "请选择")
                            Image.main.arrowIconRight
                        }
                    }
                }
            }
            .sectionStyle()
            Spacer()
            Button {
                inquiry?.addLand(newLand)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("保存")
                    .customText(size: 16, color: .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.main)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 12)
        }
        .background(Color.view.background)
        .setupNavigationBar(title: "新建土地信息") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//#Preview("CreateLand") {
//    PreviewView {
//        LandCreateView(inquiry: $0)
//    }
//}

private struct LandListView: View {
    @Binding var inquiry: Inquiry?
    
    var body: some View {
        VStack {
            Text("土地信息")
                .headerText()
            Spacer().frame(height: 20)
            VStack {
                ForEach(Array(zip(items.indices, items)), id: \.0) { idx, item in
                    itemView(for: item, idx: idx)
                    Divider()
                }
                NavigationLink {
                    LandCreateView(inquiry: $inquiry)
                } label: {
                    HStack {
                        Image.index.addIcon
                        Text("新增土地信息")
                            .customText(size: 14, color: .text.gray3)
                    }
                    .frame(height: 36)
                }
            }
        }
        .sectionStyle()
    }
    
    private var items: [LandIndustrialFactory] {
        var out = [LandIndustrialFactory(name: "主房")]
        if let l = inquiry?.landList {
            out += l
        }
        return out
    }
    
    private func itemView(for item: LandIndustrialFactory, idx: Int) -> some View {
        HStack {
            Text("\(idx+1)")
                .customText(size: 14, color: .text.gray6)
            Spacer().frame(width: 50)
            Text(item.name ?? "")
            Spacer().frame(width: 50)
            Text("\(item.area ?? "")m²")
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if idx != 0 {
                Button {
                    inquiry?.removeLand(at: idx-1)
                } label: {
                    Image.index.removeIcon
                }
            }
            NavigationLink {
                LandInfoView(land: item)
            } label: {
                Text("查看详情")
                    .customText(size: 14, color: .main)
            }
        }
    }
}

//#Preview("LandList") {
//    NavigationView {
//        PreviewView {
//            LandListView(inquiry: $0)
//        }
//    }
//}

private struct BuildInfoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let build: BuildIndustrialFactory
    
    var body: some View {
        VStack {
            ListItem(title: "建筑物", content: build.name ?? "")
            ListItem(title: "建筑面积", content: "\(build.area ?? "")m²")
            ListItem(title: "建成年份", content: build.completionDate ?? "")
            ListItem(title: "建筑结构", content: build.structure?.label ?? "")
            ListItem(title: "厂房层高", content: build.height ?? "")
        }
        .sectionStyle()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.view.background)
        .setupNavigationBar(title: "建筑物信息详情") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//#Preview("BuildInfo") {
//    BuildInfoView(build: BuildIndustrialFactory(
//        name: "建筑物",
//        area: 100,
//        completionDate: "2001",
//        structure: ._2,
//        height: "10"
//    ))
//}

private struct BuildCreateView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var inquiry: Inquiry?
    
    @State private var newBuild = BuildIndustrialFactory()
    
    private var name: Binding<String> {Binding(
        get: { newBuild.name ?? "" },
        set: { newBuild.name = $0 }
    )}
    
    private var area: Binding<String> {Binding(
        get: { newBuild.area ?? "" },
        set: { newBuild.area = $0 }
    )}
    
    private var height: Binding<String> {Binding(
        get: { newBuild.height ?? "" },
        set: { newBuild.height = $0 }
    )}

    private var date: Binding<Date> { Binding(
        get: { newBuild.completionDate?.toDate() ?? Date() },
        set: { newBuild.completionDate = $0.toString() }
    )}

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                FlexibleListItem(title: "建筑物") {
                    TextField("请输入", text: name)
                        .multilineTextAlignment(.trailing)
                }
                FlexibleListItem(title: "建筑面积") {
                    HStack {
                        TextField("请输入", text: area)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text("m²")
                    }
                }
                FlexibleListItem(title: "建成年份") {
                    Text(newBuild.completionDate ?? "请输入")
                        .foregroundColor(
                            newBuild.completionDate == nil ?
                            Color.text.grayCD :
                                    .text.gray6
                        )
                        .overlay(
                            DatePicker("date", selection: date)
                                .datePickerStyle(.compact)
                                .blendMode(.destinationOver)
                        )
                }
                FlexibleListItem(title: "建筑结构") {
                    Menu {
                        ForEach(DictType.BuildingStructure.allCases, id: \.self) { item in
                            Button {
                                newBuild.structure = item
                            } label: {
                                Text(item.label)
                            }
                        }
                    } label: {
                        HStack {
                            Text(newBuild.structure?.label ?? "请选择")
                                .foregroundColor(
                                    newBuild.structure == nil ?
                                    Color.text.grayCD :
                                            .text.gray6
                                )
                            Image.main.arrowIconRight
                        }
                    }
                }
                FlexibleListItem(title: "厂房层高") {
                    TextField("请输入", text: height)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
            }
            .sectionStyle()
            Spacer()
            Button {
                inquiry?.addBuilding(newBuild)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("保存")
                    .customText(size: 16, color: .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.main)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 12)
        }
        .background(Color.view.background)
        .setupNavigationBar(title: "新建建筑信息") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//#Preview("BuildCreate") {
//    PreviewView {
//        BuildCreateView(inquiry: $0)
//    }
//}

private struct BuildListView: View {
    @Binding var inquiry: Inquiry?
    
    var body: some View {
        VStack {
            Text("建筑物信息")
                .headerText()
            Spacer().frame(height: 20)
            VStack {
                ForEach(Array(zip(items.indices, items)), id: \.0) { idx, item in
                    itemView(for: item, idx: idx)
                    Divider()
                }
                NavigationLink {
                    BuildCreateView(inquiry: $inquiry)
                } label: {
                    HStack {
                        Image.index.addIcon
                        Text("新增土地信息")
                            .customText(size: 14, color: .text.gray3)
                    }
                    .frame(height: 36)
                }
            }
        }
        .sectionStyle()
    }
    
    private var items: [BuildIndustrialFactory] {
        var out = [BuildIndustrialFactory(name: "建筑物")]
        if let l = inquiry?.buildingList {
            out += l
        }
        return out
    }
    
    private func itemView(for item: BuildIndustrialFactory, idx: Int) -> some View {
        HStack {
            Text("\(idx+1)")
                .customText(size: 14, color: .text.gray6)
            Spacer().frame(width: 50)
            Text(item.name ?? "")
            Spacer().frame(width: 50)
            Text("\(item.area ?? "")m²")
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if idx != 0 {
                Button {
                    inquiry?.removeBuilding(at: idx-1)
                } label: {
                    Image.index.removeIcon
                }
            }
            NavigationLink {
                BuildInfoView(build: item)
            } label: {
                Text("查看详情")
                    .customText(size: 14, color: .main)
            }
        }
    }
}

//#Preview("BuildList") {
//    NavigationView {
//        PreviewView {
//            BuildListView(inquiry: $0)
//        }
//    }
//}

private struct InfoFixView: View {
    @Binding var inquiry: Inquiry?
    @Binding var roomDetail: RoomDetail
    @Binding var buildingFloor: String
    
    @Binding var isInfoFixShown: Bool
    
    private func setup() {
        items.forEach { setData(for: $0) }
    }
    
    private struct Data {
        var landUser: DictType.LandUser?
        var position: Position?
        var facing: Facing?
        var height: String = ""
        var floor1: String = ""
        var floor2: String = ""
        var completionDate: String = ""
    }
    
    @State private var data: Data = Data()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("基本信息纠错")
                .frame(maxWidth: .infinity, alignment: .center)
                .headerText()
                .overlay(
                    Button {
                        isInfoFixShown = false
                    } label: {
                        Image.index.close
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                )
            VStack {
                ForEach(items, id: \.self) { item in
                    itemView(for: item)
                }
            }
            HStack {
                Text("取消")
                    .customText(size: 16, color: .main)
                    .frame(width: 130, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main, lineWidth: 1)
                    )
                    .onTapGesture {
                        isInfoFixShown = false
                    }
                Spacer()
                Text("确定")
                    .customText(size: 16, color: .white)
                    .frame(width: 130, height: 40)
                    .background(Color.main)
                    .cornerRadius(8)
                    .onTapGesture {
                        save()
                        isInfoFixShown = false
                    }
            }
            
        }
        .sectionStyle()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
//        .ignoresSafeArea()
        .onAppear {
            setup()
        }
    }
    
    private func itemView(for item: Item) -> some View {
        HStack {
            Text(item.title)
                .customText(size: 12, color: .text.gray3)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(width: 80)
            content(for: item)
        }
        .frame(height: 28)
    }
    
    private enum Item {
        case landUser, position, facing, height, floor, completionDate
        
        var title: String {
            switch self {
            case .landUser: return "使用权类型"
            case .position: return "所在部位"
            case .facing: return "建筑朝向"
            case .height: return "地上总层"
            case .floor: return "所在层"
            case .completionDate: return "建成年份"
            }
        }
    }
    
    private func content(for item: Item) -> some View {
        switch item {
        case .landUser:
            return landUserMenu.earseToAnyView()
        case .position:
            return positionMenu.earseToAnyView()
        case .facing:
            return facingMenu.earseToAnyView()
        case .height:
            return heightInput.earseToAnyView()
        case .floor:
            return floorInput.earseToAnyView()
        case .completionDate:
            return completionDatePicker.earseToAnyView()
        }
    }
    
    private func setData(for item: Item) {
        switch item {
        case .landUser:
            data.landUser = roomDetail.landUser
        case .position:
            switch roomDetail.positionType {
            case .position:
                data.position = .position(DictType.Position(rawValue: roomDetail.positionKey))
            case .noRoomPosition:
                data.position = .noRoomPosition(DictType.NoRoomPosition(rawValue: roomDetail.positionKey))
            case .landingroomPosition:
                data.position = .landingroomPosition(DictType.LandingroomPosition(rawValue: roomDetail.positionKey))
            case .shopPosition:
                data.position = .shopPosition(DictType.ShopPosition(rawValue: roomDetail.positionKey))
            }
        case .facing:
            switch roomDetail.facingType {
            case .orientation:
                data.facing = .orientation(DictType.Orientation(rawValue: roomDetail.facingKey))
            case .buildDirection:
                data.facing = .buildDirection(DictType.BuildDirection(rawValue: roomDetail.facingKey))
            default:
                data.facing = nil
            }
        case .height:
            data.height = roomDetail.height
        case .floor:
            let floor = roomDetail.floor == nil ? buildingFloor : roomDetail.floor!
            let l = floor.components(separatedBy: "-")
            if l.count == 2 {
                data.floor1 = l[0]
                data.floor2 = l[1]
            }
        case .completionDate:
            data.completionDate = roomDetail.completionDate
        }
    }
    
    private func save(for item: Item) {
        switch item {
        case .landUser:
            inquiry?.landUser = data.landUser
            roomDetail.landUser = data.landUser
        case .position:
            switch data.position {
            case .position(let position):
                inquiry?.position = position?.dictKey
                if let p = position {
                    roomDetail.positionKey = p.dictKey
                }
            case .noRoomPosition(let noRoomPosition):
                inquiry?.position = noRoomPosition?.dictKey
                if let p = noRoomPosition {
                    roomDetail.positionKey = p.dictKey
                }

            case .landingroomPosition(let landingroomPosition):
                inquiry?.position = landingroomPosition?.dictKey
                if let p = landingroomPosition {
                    roomDetail.positionKey = p.dictKey
                }

            case .shopPosition(let shopPosition):
                inquiry?.position = shopPosition?.dictKey
                if let p = shopPosition {
                    roomDetail.positionKey = p.dictKey
                }
            case .none: break
            }
        case .facing:
            switch data.facing {
            case .orientation(let orientation):
                inquiry?.facing = orientation?.dictKey
                if let f = orientation {
                    roomDetail.facingKey = f.dictKey
                }
            case .buildDirection(let buildDirection):
                inquiry?.facing = buildDirection?.dictKey
                if let f = buildDirection {
                    roomDetail.facingKey = f.dictKey
                }
            case .none: break
            }
        case .height:
            inquiry?.height = data.height
            roomDetail.height = data.height
        case .floor:
            guard !data.floor1.isEmpty,
                  !data.floor2.isEmpty
            else { break }
            
            let floor = "\(data.floor1)-\(data.floor2)"
            inquiry?.floor = floor
            roomDetail.floor = floor
            buildingFloor = floor
        case .completionDate:
            inquiry?.completionDate = data.completionDate
            roomDetail.completionDate = data.completionDate
        }
    }
    
    private func save() { items.forEach { save(for: $0) } }
    
    private var items: [Item] {
        switch roomDetail.estateType {
        case .commApartment:
            fallthrough
        case .singleApartment:
            fallthrough
        case .villa:
            fallthrough
        case .office:
            fallthrough
        case .industrialSmallGarden:
            return [.landUser, .position, .facing, .height, .floor]
            
        case .landingRoom:
            return [.landUser, .position, .facing, .height, .floor, .completionDate]
            
        case .shopStreet:
            return [.landUser, .height, .completionDate]
            
        case .industrialFactory:
            fallthrough
        case .none:
            return []
        }
    }
    
    private var landUserMenu: some View {
        Menu {
            ForEach(DictType.LandUser.allCases, id: \.self) { i in
                print("landUserMenu key:\(i.dictKey) label:\(i.label)")
                return Button {
                    data.landUser = i
                } label: {
                    Text(i.label)
                }
            }
        } label: {
            Text(data.landUser?.label ?? "请选择\(Item.landUser.title)")
                .foregroundColor(
                    data.landUser == nil ?
                        .text.grayCD : .text.gray6
                )
                .fixViewLabelStyle()
        }
    }
    
    private enum Position {
        case position(DictType.Position?)
        case noRoomPosition(DictType.NoRoomPosition?)
        case landingroomPosition(DictType.LandingroomPosition?)
        case shopPosition(DictType.ShopPosition?)
    }
    
    private var positionMenu: some View {
        let placeholder = "请选择\(Item.position.title)"
        switch data.position {
        case .position(let position):
            return Menu {
                ForEach(DictType.Position.allCases, id: \.self) { i in
                    Button {
                        data.position = .position(i)
                    } label: {
                        Text(i.label)
                    }
                }
            } label: {
                Text(position?.label ?? placeholder)
                    .foregroundColor(
                        position == nil ?
                            .text.grayCD : .text.gray6
                    )
                    .fixViewLabelStyle()
            }
            .earseToAnyView()
        case .noRoomPosition(let noRoomPosition):
            return Menu {
                ForEach(DictType.NoRoomPosition.allCases, id: \.self) { i in
                    Button {
                        data.position = .noRoomPosition(i)
                    } label: {
                        Text(i.label)
                    }
                }
            } label: {
                Text(noRoomPosition?.label ?? placeholder)
                    .foregroundColor(
                        noRoomPosition == nil ?
                            .text.grayCD : .text.gray6
                    )
                    .fixViewLabelStyle()
            }
            .earseToAnyView()
        case .landingroomPosition(let landingroomPosition):
            return Menu {
                ForEach(DictType.LandingroomPosition.allCases, id: \.self) { i in
                    Button {
                        data.position = .landingroomPosition(i)
                    } label: {
                        Text(i.label)
                    }
                }
            } label: {
                Text(landingroomPosition?.label ?? placeholder)
                    .foregroundColor(
                        landingroomPosition == nil ?
                            .text.grayCD : .text.gray6
                    )
                    .fixViewLabelStyle()
            }
            .earseToAnyView()
        case .shopPosition(let shopPosition):
            return Menu {
                ForEach(DictType.ShopPosition.allCases, id: \.self) { i in
                    Button {
                        data.position = .shopPosition(i)
                    } label: {
                        Text(i.label)
                    }
                }
            } label: {
                Text(shopPosition?.label ?? placeholder)
                    .foregroundColor(
                        shopPosition == nil ?
                            .text.grayCD : .text.gray6
                    )
                    .fixViewLabelStyle()
            }
            .earseToAnyView()
        case .none: return EmptyView().earseToAnyView()
        }
    }
    
    private enum Facing {
        case orientation(DictType.Orientation?)
        case buildDirection(DictType.BuildDirection?)
    }
    
    private var facingMenu: some View {
        let placeholder = "请选择\(Item.facing.title)"
        switch data.facing {
        case .orientation(let orientation):
            return Menu {
                ForEach(DictType.Orientation.allCases, id: \.self) { i in
                    Button {
                        data.facing = .orientation(i)
                    } label: {
                        return Text(i.label)
                    }
                }
            } label: {
                Text(orientation?.label ?? placeholder)
                    .foregroundColor(
                        orientation == nil ?
                            .text.grayCD : .text.gray6
                    )
                    .fixViewLabelStyle()
            }
            .earseToAnyView()
        case .buildDirection(let buildDirection):
            return Menu {
                ForEach(DictType.BuildDirection.allCases, id: \.self) { i in
                    Button {
                        data.facing = .buildDirection(i)
                    } label: {
                        Text(i.label)
                    }
                }
            } label: {
                Text(buildDirection?.label ?? placeholder)
                    .foregroundColor(
                        buildDirection == nil ?
                            .text.grayCD : .text.gray6
                    )
                    .fixViewLabelStyle()
            }
            .earseToAnyView()
        case .none: return EmptyView().earseToAnyView()
        }
    }
    
    private var heightInput: some View {
        TextField("", text: $data.height)
            .foregroundColor(.text.gray3)
            .fixViewLabelStyle(showArrow: false)
            .keyboardType(.numberPad)
    }

    private var floorInput: some View {
        HStack {
            TextField("", text: $data.floor1)
                .foregroundColor(.text.gray3)
                .fixViewLabelStyle(showArrow: false)
                .keyboardType(.numberPad)
            TextField("", text: $data.floor2)
                .foregroundColor(.text.gray3)
                .fixViewLabelStyle(showArrow: false)
                .keyboardType(.numberPad)
        }
    }
    
    private var date: Binding<Date> {Binding(
        get: { data.completionDate.toDate() ?? Date() },
        set: { data.completionDate = $0.toString() }
    )}
    
    private var completionDatePicker: some View {
        HStack {
            Image.main.calendarIcon
            Text(data.completionDate.isEmpty || data.completionDate == "无" ? "请选择\(Item.completionDate.title)" : data.completionDate)
        }
        .overlay (
            DatePicker("date", selection: date, in: ...Date(), displayedComponents: [.date])
                .blendMode(.destinationOver)
        )
        .foregroundColor(
            data.completionDate.isEmpty || data.completionDate == "无" ?
                .text.grayCD : .text.gray3
        )
        .fixViewLabelStyle()
    }
}

/*
private struct InfoFixPreviewView: View {
    @State var inquiry: Inquiry?
    @State var detail: RoomDetail
    
    init(estateType: DictType.EstateType) {
        self.inquiry = Self.inquiry(with: estateType)
        self.detail = Self.detail(with: estateType)
    }
    
    var body: some View {
        InfoFixView(inquiry: $inquiry, roomDetail: $detail, isInfoFixShown: .constant(true))
    }
    
    static private func inquiry(with estateType: DictType.EstateType) -> Inquiry {
        var out = Inquiry.empty
        out.estateType = estateType
        return out
    }
    
    static private func detail(with estateType: DictType.EstateType) -> RoomDetail {
        var out = RoomDetail.empty
        out.estateType = estateType
        return out
    }
}

#Preview("InfoFixView") {
    InfoFixPreviewView(estateType: .commApartment)
}
 */

private struct ReferenceCaseView: View {
    @EnvironmentObject var estateService: EstateService
    
    let inquiry: Inquiry?
    let detail: RoomDetail
    @State private var caseList: [ReferenceCase] = []
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack(spacing: 10) {
                view(for: headerItem, isHeader: true)
                ForEach(Array(zip(caseList.indices, caseList)), id: \.0) { _, item in
                    view(for: item, isHeader: false)
                }
            }
            .customText(size: 14, color: .text.gray3)
            .padding(.bottom, 20)
            .onAppear {
                Task {
                    caseList = await estateService.getCaseList(
                        compoundId: inquiry?.compoundId ?? 0,
                        estateType: inquiry?.estateTypeString ?? "",
                        price: Double(inquiry?.price ?? "") ?? 0
                    )
                }
            }
        }
    }
    
    private func view(for item: ReferenceCase, isHeader: Bool) -> some View {
        HStack(spacing: 4) {
            caseText(item.compoundName.isEmpty ? detail.compoundName : item.compoundName, isHeader: isHeader)
            caseText(item.caseAddress, isHeader: isHeader)
            caseText(item.tradeType, isHeader: isHeader)
            caseText(item.area, isHeader: isHeader)
            caseText(item.date, isHeader: isHeader)
            caseText(item.totalPrice, isHeader: isHeader)
            caseText(item.floor, isHeader: isHeader)
            caseText(item.price, isHeader: isHeader)
            caseText(item.totalPrice, isHeader: isHeader)
            caseText(item.decorate, isHeader: isHeader)
        }
    }
    
    private func caseText(_ text: String, isHeader: Bool) -> some View {
        Text(text)
            .lineLimit(2)
            .frame(width: 53, height: 40)
            .background(isHeader ? headerBgColor : .white)
    }
    
    private var headerItem: ReferenceCase {
        ReferenceCase(
            tradeType: "交易种类",
            date: "案例日期",
            caseAddress: "案例地址",
            decorate: "装修",
            floor: "楼层区间",
            price: "案例单价(万元)",
            totalPrice: "案例总价(万元)",
            area: "面积(m²)",
            compoundAddress: "小区地址",
            totalFloor: "总楼层",
            compoundName: "小区名称"
        )
    }
    
    private var headerBgColor: Color {
        .hex("#D8E5FF")
    }
}

//#Preview("ReferenceCase") {
//    ReferenceCaseView(inquiry: .empty, detail: .empty)
//        .environmentObject(EstateService.preview)
//}

private struct BannerView: View {
    @State private var selected: Int = 1
    
    @Binding var roomDetail: RoomDetail
    
    private var imageURLs: [URL] {
        roomDetail.imageList.compactMap { URL(string: $0) }
    }
    
    var body: some View {
        TabView {
            if imageURLs.isEmpty {
                Image.main.placeholder
            } else {
                ForEach(imageURLs, id: \.self) { bannerURL in
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
//    BannerView(roomDetail: .constant(.empty))
//}

private struct ChartPage: View {
    @Binding var inquiry: Inquiry?
    @Binding var roomDetail: RoomDetail
    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var accountService: AccountService
    
    @State private var basePrice: Double = 0
    @State private var basePriceDate: String = ""
    @State private var startTime: String?
    @State private var endTime: String?
    @State private var startTimePickerShown = false
    @State private var endTimePickerShown = false
    @State private var compoundCurve: [Curve] = []
    @State private var districtCurve: [Curve] = []

    var body: some View {
        VStack(spacing: 0) {
            topView
            Spacer().frame(height: 30)
            VStack {
                HStack {
                    Text("\(roomDetail.compoundName)走势图").headerText()
                    Spacer()
                    Image.index.pointIcon
                    Text("价格走势")
                        .customText(size: 14, color: .text.gray3)
                }
                ChartView(curves: $compoundCurve)
                    .frame(height: 157)
            }
            .sectionStyle()
            Spacer().frame(height: 10)
            VStack {
                HStack {
                    Text("\(roomDetail.areaName)走势图").headerText()
                    Spacer()
                    Image.index.pointIcon
                    Text("价格走势")
                        .customText(size: 14, color: .text.gray3)
                }
                ChartView(curves: $districtCurve)
                    .frame(height: 157)
            }
            .sectionStyle()
        }
        .onAppear {
            let today = Date()
            var dc = DateComponents()
            dc.month = -11
            let date = Calendar.current.date(byAdding: dc, to: today)
            endTime = today.toString(format: "YYYY-MM")
            startTime = date?.toString(format: "YYYY-MM") ?? endTime
            getCurve()
        }
        .onChange(of: startTime) { _ in
            getCurve()
        }
        .onChange(of: endTime) { _ in
            getCurve()
        }
    }
    
    private var baseDate: String {
        basePriceDate.isEmpty ? Date().toString(format: "YYYY-MM") : basePriceDate
    }
    private var topView: some View {
        VStack(spacing: 0) {
            Text("\(roomDetail.compoundName)\(baseDate)月基准价")
                .headerText()
            Spacer().frame(height: 16)
            HStack {
                Text("类型")
                    .customText(size: 14, color: .text.gray6)
                Text(roomDetail.estateType?.label ?? "")
                    .customText(size: 14, color: .text.gray3)
                Spacer()
                Text("物业分类")
                    .customText(size: 14, color: .text.gray6)
                Text(roomDetail.wuYeFenLeiText)
                    .customText(size: 14, color: .text.gray3)
                Spacer()
                Text("基准价")
                    .customText(size: 14, color: .text.gray6)
                Text("\(Int(basePrice))/m²")
                    .customText(size: 14, color: .text.gray3)
            }
            Spacer().frame(height: 16)
            HStack(spacing: 13) {
                YearMonthButton(placeholder: "开始日期", isShown: $startTimePickerShown, time: $startTime)
                Text("-").customText(size: 16, color: .text.gray3)
                YearMonthButton(placeholder: "结束日期", isShown: $endTimePickerShown, time: $endTime)
                Spacer()
            }
        }
        .sectionStyle(vPadding: 0)
    }
    
    @State private var task: Task<Void, Never>?
    
    private func getCurve() {
        guard task == nil else { return }
        
        task = Task {
            let s = startTime ?? Date().toString(format: "YYYY-MM")
            let e = endTime ?? s
            compoundCurve = [await Curve.compoundCurve(
                districtId: roomDetail.areaCode,
                compoundId: roomDetail.compoundId,
                startTime: s, endTime: e,
                estateType: roomDetail.estateType?.dictKey ?? "")]
            districtCurve = [await Curve.baseDistrictCurve(
                districtId: roomDetail.areaCode,
                compoundId: roomDetail.compoundId,
                startTime: s, endTime: e,
                estateType: roomDetail.estateType?.dictKey ?? "")]
            (basePriceDate, basePrice) = await estateService.getBaseCompoundPrice(
                districtId: roomDetail.areaCode,
                compoundId: roomDetail.compoundId,
                estateType: roomDetail.estateType?.dictKey ?? "",
                startTime: s, endTime: e,
                wuYeFenLei: roomDetail.wuYeFenLei
            )
            task = nil
        }
    }
}

#Preview("ChartPage") {
    PreviewView { inquiry, roomDetail in
        ChartPage(inquiry: inquiry, roomDetail: roomDetail)
            .onAppear {
                roomDetail.wrappedValue.compoundName = "杭州市壹号院"
                roomDetail.wrappedValue.estateType = DictType.EstateType.commApartment
                roomDetail.wrappedValue.wuYeFenLei = "多层"
                roomDetail.wrappedValue.compoundId = 2
                roomDetail.wrappedValue.areaName = "西湖区"
            }
            .frame(maxHeight: .infinity)
            .background(Color.black)
    }
    .environmentObject(EstateService.preview)
}


// MARK: -

private struct ListItem: View {
    let title: String
    let content: String
    
    var body: some View {
        HStack {
            Text(title).itemTitle()
            Spacer()
            Text(content).itemContent()
        }
        .frame(height: 36)
    }
}

private struct FlexibleListItem<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack {
            Text(title).itemTitle()
            Spacer()
            content()
                .itemContent()
        }
        .frame(height: 36)
    }
}

private struct Divider: View {
    var body: some View {
        Color.hex("#F3F3F3")
            .frame(height: 1)
    }
}

private struct FixViewItemLabelModifier: ViewModifier {
    let showArrow: Bool
    
    func body(content: Content) -> some View {
        content
            .customText(size: 12, color: .text.grayCD)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.hex("#F2F2F2"), lineWidth: 1.0)
            )
            .overlay(
                Image.main.arrowIconDown
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
                    .opacity(showArrow ? 1 : 0)
            )
    }
}
private extension View {
    func fixViewLabelStyle(showArrow: Bool = true) -> some View {
        modifier(FixViewItemLabelModifier(showArrow: showArrow))
    }
}


private struct PreviewView<Content: View>: View {
    @State var inquiry: Inquiry? = .empty
    @State var roomDetail: RoomDetail = .empty
    
    let content: (_ inquiry: Binding<Inquiry?>, _ roomDetail: Binding<RoomDetail>) -> Content
    
    var body: some View {
        NavigationView {
            content($inquiry, $roomDetail)
        }
    }
    
    func setEstateType(_ type: DictType.EstateType) -> some View {
        _ = inquiry?.setEstateType(type)
        return self
    }
}

private extension Inquiry {
    mutating func prepareAuxiliaryRoomList() -> Inquiry {
        addAuxiliaryRoom(.fixedRoom(with: "200"))
        return self
    }
    
    mutating func setEstateType(_ type: DictType.EstateType) -> Inquiry {
        setString("fvEstateType", of: type.dictKey)
        return self
    }
}

private extension AuxiliaryRoom {
    static func new() -> AuxiliaryRoom {
        AuxiliaryRoom(propertyAttribute: nil, commonHas: nil, unit: nil, area: nil)
    }
    
    var name: String {
        switch propertyAttribute {
        case .mainHouse: return DictType.MainHouse.mian.label
        case .auxiliaryHouse(let subType):
            return subType?.label ?? ""
        case .appendages(let subType):
            return subType?.label ?? ""
        default: return ""
        }
    }
}

private extension Account {
    func hasPermission(_ permission: String) -> Bool {
        return permissions.contains(permission)
    }
    
    var roomDetailTabs: [RoomDetailTab] {
        var out = [RoomDetailTab]()
        if hasPermission("估价详情") {
            out.append(.inquiryDetail)
        }
        if hasPermission("参考案例") {
            out.append(.reference)
        }
        if hasPermission("价格走势") {
            out.append(.chart)
        }
        if hasPermission("房产详情") {
            out.append(.estateDetail)
        }
        return out
    }
    
    var firstTab: RoomDetailTab? {
        return roomDetailTabs.first
    }
    
    var canShowMapView: Bool {
        return hasPermission("地图定位")
    }
    
    var canExtendDetail: Bool {
        return hasPermission("展开估价结果")
    }
    
    var canShowDecorateView: Bool {
        return hasPermission("室内因素")
    }
    
    var canShowAuxiliaryView: Bool {
        return hasPermission("辅房及其附属物")
    }
    
    var cahShowAdjustView: Bool {
        return hasPermission("结果调整")
    }
}

