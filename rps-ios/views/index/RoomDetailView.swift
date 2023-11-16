//
//  RoomDetailView.swift
//  rps-ios
//
//  Created by serika on 2023/11/13.
//

import SwiftUI

struct RoomDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var accountService: AccountService
    
    private var roomDetail: RoomDetail { estateService.roomDetail }
    
    let familyRoomName: String
    let areaCode: Int
    let estateType: String
    let buildingId: Int
    let floor: String
    
    @State private var inquiry: Inquiry? {
        didSet {
            guard let area = inquiry?.area else { return }
            areaText = "\(area)"
        }
    }
    
    @State private var initialized: Bool = false
    @State private var hasInquiryResult: Bool = false
    @State private var detailExtened: Bool = false
    @State private var areaText: String = ""
    
    var body: some View {
        ZStack {
            Color.view.background
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
            VStack(spacing: 0) {
                ScrollView {
                    ZStack(alignment: .top) {
                        Color.gray
                            .frame(height: 252)
                            .frame(maxHeight: .infinity, alignment: .top)
                        VStack(spacing: 10) {
                            Spacer().frame(height: 219)
                            content
//                            Spacer().frame(height: 10)
                            mapView
//                            Spacer().frame(height: 10)
                            if hasInquiryResult {
                                ResultView(inquiry: inquiry!, detailExtened: $detailExtened)
//                                Spacer().frame(height: 10)
                                actionView
//                                Spacer().frame(height: 10)
                            }
                            if detailExtened {
                                DecorateView()
//                                Spacer().frame(height: 10)
                                if inquiry != nil {
                                    AuxiliaryRoomListView(inquiry: $inquiry)
                                }
                            }
                        }
                    }
                }
                OverlayView(
                    areaText: $areaText,
                    inquiry: $inquiry,
                    hasInquiryResult: $hasInquiryResult,
                    detailExtened: $detailExtened
                )
            }
        }
        .setupNavigationBar(title: "系统询价详情") {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            Task {
                guard !initialized else { return }
                
                await estateService.getRoomDetail(
                    estateType: estateType,
                    areaCode: areaCode,
                    familyRoomName: familyRoomName,
                    buildingId: buildingId
                )
                inquiry = await estateService.createInquiry(buildingId: buildingId, estateType: estateType, areaCode: areaCode, searchAddr: familyRoomName, orgId: accountService.account?.orgId ?? 0)
                initialized = true
            }
        }
    }
    
    @State private var selectedTab: RoomDetailTab = .inquiryDetail
    
    private var content: some View {
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
            tabView
        }
        .sectionStyle()
    }
    
    private var tabView: some View {
        RoomInfoView(floor: floor)
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
                Color.gray
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
                actionItem(title: "获取报告单")
                Spacer()
                actionItem(title: "估价师询价")
                Spacer()
                actionItem(title: "委托报告")
            }
            HStack {
                actionItem(title: "价格反馈")
                Spacer()
                actionItem(title: "复制询价")
                Spacer()
                actionItem(title: "历史信息")
            }
        }
        .sectionStyle()
    }
    
    private func actionItem(title: String) -> some View {
        Text(title)
            .customText(size: 14, color: .main)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color.white)
            .cornerRadius(15)
            .overlay (
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.main, lineWidth: 1)
            )
    }
    
}

private enum RoomDetailTab: CaseIterable {
    case inquiryDetail, reference
    
    var title: String {
        switch self {
        case .inquiryDetail: return "估价详情"
        case .reference: return "参考案例"
        }
    }
}

private struct RoomDetailTabView: View {
    @Binding var selectedTab: RoomDetailTab
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(RoomDetailTab.allCases, id: \.hashValue) { tab in
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

private struct RoomInfoView: View {
    @EnvironmentObject var estateService: EstateService
    
    let floor: String
    
    private var roomDetail: RoomDetail { estateService.roomDetail }
    private var estateType: EstateType? { roomDetail.estateType }
//    private var estateType: EstateType? { EstateType.shopStreet }
    
    var body: some View {
        VStack {
            HStack {
                Text("基本信息")
                    .customText(size: 16, color: .text.gray3, weight: .medium)
                Spacer()
                Text("基本信息纠错")
                    .customText(size: 14, color: .white)
                    .frame(height: 30)
                    .padding(.horizontal, 10)
                    .background(Color.main)
                    .cornerRadius(15)
            }
            Spacer().frame(height: 17)
            HStack {
                Text("产权地址")
                    .customText(size: 14, color: .text.gray6)
                Text(estateService.roomDetail.address)
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
        case .landUser: return roomDetail.landUser
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
}

private struct OverlayView: View {
    @EnvironmentObject var estateService: EstateService
    
    @Binding var areaText: String
    @Binding var inquiry: Inquiry?
    @Binding var hasInquiryResult: Bool
    @Binding var detailExtened: Bool
    
    var body: some View {
        VStack {
            if canShowInquiry {
                inquiryView
            }
            if canShowExtendButton {
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
    
    private var inquiryView: some View {
        HStack {
            HStack {
                TextField("请输入建筑面积", text: $areaText)
                Text("估一下")
                    .customText(size: 14, color: .white)
                    .frame(width: 81, height: 36)
                    .background(Color.hex("#FFB23F"))
                    .cornerRadius(8)
                    .onTapGesture {
                        Task {
                            guard var inquiry = inquiry,
                                  let area = Double(areaText)
                            else { return }
                            
                            inquiry.area = area
                            inquiry = await estateService.inquire(inquiry: inquiry)
                            hasInquiryResult = true
                        }
                    }
            }
            .padding(.horizontal, 16)
        }
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
            ListItem(title: "房产评估单价", content: "\(inquiry.price)元/m²")
            Spacer().frame(height: 10)
            ListItem(title: "房产评估总价", content: "\(inquiry.totalPrice)元")
            Spacer().frame(height: 10)
            ListItem(title: "估价时间", content: "\(inquiry.date)")
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

private struct DecorateView: View {
    var body: some View {
        VStack {
            VStack {
                Text("室内因素")
                    .headerText()
                Spacer().frame(height: 20)
                planeShapePicker
                divider
                levelDecoratePicker
                divider
                decorateDatePicker
            }
            .sectionStyle()
        }
    }
    
    private var divider: some View {
        Color.view.background
            .frame(height: 1)
    }
    
    @State private var planeShape: PlaneShape?
    private var planeShapePicker: some View {
        Menu {
            Picker("", selection: $planeShape) {
                ForEach(PlaneShape.allCases, id: \.self) { shape in
                    Text(shape.label)
                }
            }
        } label: {
            HStack {
                Text("户型布局")
                Spacer()
                Text(planeShape?.label ?? "请选择户型布局")
                Image.main.arrowIconRight
            }
            .customText(size: 14, color: .text.gray6)
            .frame(height: 36)
        }
    }
    
    @State private var levelDecorate: LevelDecorate?
    private var levelDecoratePicker: some View {
        Menu {
            Picker("", selection: $levelDecorate) {
                ForEach(LevelDecorate.allCases, id: \.self) { deco in
                    Text(deco.label)
                }
            }
        } label: {
            HStack {
                Text("装修情况")
                Spacer()
                Text(levelDecorate?.label ?? "请选择装修情况")
                Image.main.arrowIconRight
            }
            .customText(size: 14, color: .text.gray6)
            .frame(height: 36)
        }
    }
    
    @State private var date: Date = Date()
    private var decorateDatePicker: some View {
        HStack {
            Text("装修时间")
            Spacer()
            Text(date.toString(format: "YYYY-MM-dd"))
            Image.main.arrowIconRight
        }
        .customText(size: 14, color: .text.gray6)
        .frame(height: 36)
        .overlay (
            DatePicker("date", selection: $date, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(.compact)
                .blendMode(.destinationOver)
        )
    }
}

private struct AuxiliaryRoomListView: View {
    
    @Binding var inquiry: Inquiry?
    
    private var roomList: [AuxiliaryRoom] {
        var out: [AuxiliaryRoom] = [.fixedRoom(with: inquiry?.area ?? 0)]
        if inquiry != nil {
            out += inquiry!.auxiliaryRoomList
        }
        return out
    }
    
    var body: some View {
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
            ListItem(title: "计算面积", content: room.areaText)
        }
        .sectionStyle()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.view.background)
    }
    
}

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
        get: {
            if let area = newRoom.area {
                return "\(area)"
            } else {
                return ""
            }
        },
        set: { value in
            newRoom.area = Double(value)
        }
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

private extension AuxiliaryRoom {
    static func fixedRoom(with area: Double) -> AuxiliaryRoom {
        AuxiliaryRoom(
            propertyAttribute: .mainHouse,
            commonHas: .has, unit: "m²",
            area: area
        )
    }
}

private struct HeaderTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .customText(size: 16, color: .text.gray3, weight: .medium)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
private extension View {
    func headerText() -> some View {
        modifier(HeaderTextModifier())
    }
    func itemTitle() -> some View {
        modifier(CustomText(size: 14, color: .text.gray3, weight: .regular))
    }
    
    func itemContent() -> some View {
        modifier(CustomText(size: 14, color: .text.gray6, weight: .regular))
    }
}

private struct SectionStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 12)
    }
}
private extension View {
    func sectionStyle() -> some View {
        modifier(SectionStyleModifier())
    }
}

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

// MARK: - preview
#Preview {
    NavigationView {
        RoomDetailView(
            familyRoomName: "宝石1幢1单元RF301",
            areaCode: 300106,
            estateType: "singleApartment",
            buildingId: 1,
            floor: "1-1"
        )
        .environmentObject(
            EstateService()
                .setRoomDetail(.mock)
        )
        .environmentObject(AccountService())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("online") {
    Box.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJycHNfdXNlcjo0MCIsInJuU3RyIjoiR3Uza1VDRlp0WENiUnNQbnZFbzR6bHdSbmdQNXFQQmoiLCJ1c2VySWQiOjQwfQ.vWHDeE0OHg2ldyTlnCDSFN9p67IoqQyU1jhzZncRIEo")
    Task {
        await DictType.getDict()
    }
    return NavigationView {
        RoomDetailView(
            familyRoomName: "路段1号101",
            areaCode: 300106,
            estateType: "shopStreet",
            buildingId: 1,
            floor: "1-1"
        )
        .environmentObject( EstateService() )
        .environmentObject(AccountService())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("ResultView") {
    ResultView(inquiry: .empty, detailExtened: .constant(true))
}

#Preview("DecorateView") {
    return DecorateView()
        .background(Color.view.background)
}

private struct AuxiliaryRoomListPreview: View {
    @State private var inquiry: Inquiry? = .empty
    
    var body: some View {
        NavigationView {
            AuxiliaryRoomListView(inquiry: $inquiry)
        }
    }
}

#Preview("AuxiliaryRoomListView") {
    AuxiliaryRoomListPreview()
}

#Preview("AuxiliaryRoomView") {
    AuxiliaryRoomInfoView(room: AuxiliaryRoom(propertyAttribute: .auxiliaryHouse(subType: .attic), commonHas: .not, unit: "m", area: 200))
        .background(Color.black)
}

#Preview("AuxiliaryRoomCreateView") {
    AuxiliaryRoomCreateView(inquiry: .constant(.empty))
}

#Preview("Overlay") {
    VStack {
        Text("估一下")
        OverlayView(
            areaText: .constant("100"),
            inquiry: .constant(.empty),
            hasInquiryResult: .constant(false),
            detailExtened: .constant(false)
        )
        Text("估一下 + 展开")
        OverlayView(
            areaText: .constant("100"),
            inquiry: .constant(.empty),
            hasInquiryResult: .constant(true),
            detailExtened: .constant(false)
        )
        Text("详细估价")
        OverlayView(
            areaText: .constant("100"),
            inquiry: .constant(.empty),
            hasInquiryResult: .constant(true),
            detailExtened: .constant(true)
        )
    }
}

/*
 */
private struct TestData {
    var textList: [String] = []
}

private struct TestView: View {
    @State private var inquiry: Inquiry = .empty
    
    private var list: [AuxiliaryRoom] {
        inquiry.auxiliaryRoomList
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(Array(zip(list.indices, list)), id: \.0) { _, room in
                    Text(room.name)
                }
                NavigationLink {
                    TestAddView(inquiry: $inquiry)
                } label: {
                    Text("add")
                }
            }
        }
    }
}

private struct TestAddView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var inquiry: Inquiry
    @State private var room = AuxiliaryRoom.new()
    
    var body: some View {
        Button("add") {
            room.propertyAttribute = .appendages(subType: .attic)
            room.commonHas = .has
            room.unit = "m"
            room.area = 100
            inquiry.addAuxiliaryRoom(room)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    TestView()
}

// MARK: - preview end

private extension EstateService {
    func setRoomDetail(_ roomDetail: RoomDetail) -> EstateService {
        self.roomDetail = roomDetail
        return self
    }
}

private extension Inquiry {
    mutating func prepareAuxiliaryRoomList() -> Inquiry {
        addAuxiliaryRoom(.fixedRoom(with: 200))
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
    
    var areaText: String {
        "\(area ?? 0)\(unit ?? "")"
    }
}


