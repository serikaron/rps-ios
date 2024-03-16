//
//  MapView.swift
//  rps-ios
//
//  Created by serika on 2023/11/23.
//

import SwiftUI
import MAMapKit
//import SBPAsyncImage
import Combine

struct MapSearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var estateService: EstateService
    @EnvironmentObject var tabService: TabService
 
    @State private var inputText = ""
    @State private var showMap = true
    @State private var compound: MapCompound?
    @State private var showPopover = false
    
    var body: some View {
        ZStack {
//            Color.gray
            MapView(mapViewCoordinate: compound?.coordinate)
            content
            Image.index.mapBack
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 60)
                .padding(.leading, 20)
//                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .keyboardAdaptive()
        .edgesIgnoringSafeArea(.vertical)
        .navigationBarHidden(true)
        .onAppear {
            TabBarModifier.hideTabBar()
            tabService.isHidden = true
        }
        .onDisappear {
            TabBarModifier.showTabBar()
            tabService.isHidden = false
        }
        .sheet(isPresented: $showPopover) {
            ResultListView(show: $showPopover, compound: $compound, keyword: inputText)
                .presentationDetents([.height(350)])
        }
    }
    
    @State private var keyboardHeight: CGFloat = 0
    
    private var content: some View {
        VStack {
            infoView
            Spacer().frame(height: 100)
            inputView
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 40)
    }
    
    private var infoView: some View {
        Group {
            if let compound = compound {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: compound.picUrl), scale: 1.0) { image in
                        image.resizable()
                    } placeholder: {
                        Image.main.placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(height: 125)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer().frame(height: 10)
                    HStack {
                        Text(compound.name).headerText()
                        Text(compound.alias)
                            .customText(size: 13, color: .hex("#DF9424"))
                            .padding(.horizontal, 4)
                            .frame(height: 24)
                            .background(Color.hex("#FFEFD8"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                        NavigationLink {
                            BuildingsView(comId: compound.compoundId, estateType: compound.estateType)
                            //                            RoomDetailView(
//                                familyRoomName: compound.familyRoomName,
//                                areaCode: compound.areaCode,
//                                estateType: compound.estateType,
//                                buildingId: compound.buildingId,
//                                area: "",
//                                floor: compound.floor)
                        } label: {
                            HStack {
                                Text("查看楼幢")
                                Image.main.arrowIconRight
                            }
                            .customText(size: 13, color: .hex("#4174F8"))
                            .padding(.horizontal, 10)
                            .frame(height: 30)
                            .background(Color.hex("#D9E3FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    Spacer().frame(height: 20)
                    HStack(spacing: 5) {
                        itemView(title: "小区东至", content: compound.east)
                        divider
                        itemView(title: "小区南至", content: compound.south)
                        divider
                        itemView(title: "小区西至", content: compound.west)
                        divider
                        itemView(title: "小区北至", content: compound.north)
                    }
                    .frame(width: 350)
                    Spacer().frame(height: 20)
                    HStack(spacing: 5) {
                        itemView(title: "路牌号", content: compound.streetMark)
                        divider
                        itemView(title: "区域位置", content: compound.location)
                        Spacer()
                    }
                    .frame(width: 350)
                }
                .sectionStyle()
                .shadow(radius: 10)
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 30) {
            HStack {
                TextField("", text: $inputText)
                Spacer()
                Image.main.searchIcon
            }
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .hex("#525050").opacity(0.3), radius: 3)
            
            Text("地图找房")
                .customText(size: 16, color: .white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.main)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture {
                    hideKeyboard()
                    Task {
//                        compound = await estateService.searchMap(address: inputText)
                        await estateService.exactSearch(keyword: inputText)
                        showPopover = true
                    }
                }
        }
        .padding(.vertical, 40)
        .sectionStyle()
        .shadow(radius: 10)
    }
    
    private func itemView(title: String, content: String) -> some View {
        VStack {
            Text(title).itemContent()
            Spacer()
            Text(content).customText(size: 13, color: .text.gray3)
        }
        .frame(width: 80, height: 52)
    }
    
    private var divider: some View {
        Color.hex("#F3F3F3")
            .frame(width: 1, height: 52)
    }
}

private struct ResultListView: View {
    @EnvironmentObject private var estateService: EstateService
    var show: Binding<Bool>
    
    @State private var pickerValue: Int = 0
    @Binding var compound: MapCompound?
    let keyword: String
    
    private var resultList: [SearchResult] {
        estateService.exactSearchResult
    }
    
    private func text(for searchResult: SearchResult) -> String {
        (searchResult.networkData.fvProvinceName ?? "")
        + "-" + (searchResult.networkData.fvCityName ?? "")
        + "-" + (searchResult.networkData.fvAreaName ?? "")
        + "-" + (searchResult.networkData.fvSubdistrictName ?? "")
        + "-" + (searchResult.networkData.fvCompoundName ?? "")
        + "-(" + (searchResult.networkData.fvNameAlias ?? "") + ")"
    }
    
    var body: some View {
        VStack {
            actionRow
            picker
        }
        .padding()
    }
    
    private var actionRow: some View {
        HStack {
            Text("取消")
                .customText(size: 14, color: .text.gray6)
                .background(.white)
                .onTapGesture {
                    show.wrappedValue = false
                }
            Spacer()
            Text("确定")
                .customText(size: 14, color: .text.gray3)
                .background(.white)
                .onTapGesture {
                    show.wrappedValue = false
                    if !resultList.isEmpty {
                        compound = MapCompound.fromSearchResult(resultList[pickerValue].networkData)
                    }
                }
        }
    }
    
    private var picker: some View {
        Picker("", selection: $pickerValue) {
            ForEach(resultList.indices, id: \.self) { i in
                Text(text(for: resultList[i]))
                    .tag(i)
                    .onAppear {
                        if i == resultList.count - 2 {
                            Task {
                                await estateService.exactSearch(keyword: keyword)
                            }
                        }
                    }
            }
        }
        .pickerStyle(.wheel)
    }
}

#Preview("MapSearch") {
    MapService.initMAMapKit()
    return MapSearchView()
        .environmentObject(EstateService.preview)
        .environmentObject(TabService())
}

//
//#Preview {
//    MapView()
//}
