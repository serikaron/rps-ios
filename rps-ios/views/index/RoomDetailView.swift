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
        RoomInfoView()
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
    
    private var roomDetail: RoomDetail { estateService.roomDetail }
    
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
            shopStreetView
        }
        .padding(.horizontal, 16)
    }
    
    private var shopStreetView: some View {
        VStack(spacing: 10) {
            HStack {
                item(title: "物业类型", content: roomDetail.estateType, isRight: false)
                item(title: "使用权类型", content: roomDetail.landUser, isRight: true)
            }
            HStack {
                item(title: "建成年份", content: roomDetail.completionDate, isRight: false)
                item(title: "所在部位", content: roomDetail.position, isRight: true)
            }
            HStack {
                item(title: "建筑结构", content: roomDetail.structure, isRight: false)
                item(title: "建筑朝向", content: roomDetail.facing, isRight: true)
            }
            HStack {
                item(title: "地上总层", content: roomDetail.height, isRight: false)
                item(title: "所在楼层", content: roomDetail.floor, isRight: true)
            }
            HStack {
                item(title: "房屋性质", content: roomDetail.property, isRight: false)
                item(title: "房屋用途", content: roomDetail.usage, isRight: true)
            }
        }
    }
    
    private func item(title: String, content: String, isRight: Bool) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .customText(size: 14, color: .text.gray6)
            Text(content)
                .customText(size: 14, color: .text.gray3)
        }
    }
}

private enum RoomInfoItem {
    case estateType
}

#Preview {
    NavigationView {
        RoomDetailView(
            familyRoomName: "宝石1幢1单元RF301",
            areaCode: 300106,
            estateType: "singleApartment",
            buildingId: 1
        )
        .environmentObject(
            EstateService()
                .setRoomDetail(.mock)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("online") {
    Box.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJycHNfdXNlcjo0MCIsInJuU3RyIjoiS1B4S1lsRk9HWjRlaVNTUld4RWFBUFNoWVZrZkZWTU8iLCJ1c2VySWQiOjQwfQ.RX-aZ1RW-dht1RpMH_-St3dKS82k1Qp5aoDgSIUsW0Y")
    return NavigationView {
        RoomDetailView(
            familyRoomName: "宝石1幢1单元RF301",
            areaCode: 300106,
            estateType: "singleApartment",
            buildingId: 1
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
