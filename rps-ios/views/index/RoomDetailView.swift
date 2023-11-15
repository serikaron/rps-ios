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
    
    private var roomDetail: RoomDetail { estateService.roomDetail }
    
    let familyRoomName: String
    let areaCode: Int
    let estateType: String
    let buildingId: Int
    let floor: String
    
    var body: some View {
        ZStack {
            Color.view.background
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
            ScrollView {
                ZStack(alignment: .top) {
                    Color.gray
                        .frame(height: 252)
                        .frame(maxHeight: .infinity, alignment: .top)
                    VStack(spacing: 0) {
                        Spacer().frame(height: 219)
                        content
                    }
                }
            }
            inquiryLayer
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .setupNavigationBar(title: "系统询价详情") {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            Task {
                await estateService.getRoomDetail(
                    estateType: estateType,
                    areaCode: areaCode,
                    familyRoomName: familyRoomName,
                    buildingId: buildingId
                )
            }
        }
    }
    
    @State private var selectedTab: RoomDetailTab = .inquiryDetail
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 20)
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
            Spacer().frame(height: 30)
            mapView
            Spacer().frame(height: 20)
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 12)
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
        .padding(.horizontal, 16)
    }
    
    @State private var areaText: String = ""
    
    private var inquiryLayer: some View {
        HStack {
            HStack {
                TextField("请输入建筑面积", text: $areaText)
                Text("估一下")
                    .customText(size: 14, color: .white)
                    .frame(width: 81, height: 36)
                    .background(Color.hex("#FFB23F"))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 50)
        .background(Color.white)
        .padding(.horizontal, 12)
        .cornerRadius(8)
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
                    .customText(size: 16, color: .text.gray3)
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
                            itemView(title: title(for: item), content: value(for: item))
                            if idx == row.count - 1 {
                                if row.count != 4 {
                                    Spacer().earseToAnyView()
                                }
                            } else {
                                divider.earseToAnyView()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.horizontal, 16)
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
        .frame(width: 77)
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
        print("itemToShow, estateType: \(estateType)")
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

private enum RoomInfoItem {
    case estateType, landUser, completionDate, position, structure, facing, height, floor, landLevel, usage, property, landingroomUsage
}

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
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EstateService {
    func setRoomDetail(_ roomDetail: RoomDetail) -> EstateService {
        self.roomDetail = roomDetail
        return self
    }
}
