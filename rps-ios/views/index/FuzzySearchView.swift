//
//  FuzzySearchView.swift
//  rps-ios
//
//  Created by serika on 2023/11/10.
//

import SwiftUI

struct FuzzySearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var estateService: EstateService
    @EnvironmentObject private var areaTreeService: AreaTreeService
    @EnvironmentObject private var accountService: AccountService
    
    @State private var nextAction: NextAction = .exactSearch
    @State private var showExactSearchView = false
    @State private var disableSearch = false
    
    @State private var showDetail = false
    
    @State private var areaTreeData = AreaTreeData.empty
    
    var body: some View {
        ZStack {
            NavigationLink(isActive: $showExactSearchView) {
                ExactSearchView(text: estateService.fuzzyKeyword)
                    .environmentObject(estateService)
            } label: {
                EmptyView()
            }
            
            NavigationLink(isActive: $showDetail) {
                RoomDetailView(
                    familyRoomName: selectedRoomInfo?.roomName ?? "",
                    areaCode: selectedRoomInfo?.areacode ?? 0,
                    estateType: selectedRoomInfo?.estateType ?? "",
                    buildingId: selectedRoomInfo?.buildingId ?? 0,
                    area: "",
                    dataOrgId: selectedRoomInfo?.orgId ?? 0,
                    floor: selectedRoomInfo?.floor ?? "无"
                )
                    .environmentObject(estateService)
            } label: {
                EmptyView()
            }


            VStack {
                Spacer().frame(height: 10)
                areaPicker
                Spacer().frame(height: 10)
                SearchInputView(text: $estateService.fuzzyKeyword, searchAction: {
                    guard !estateService.fuzzyKeyword.isEmpty else { return }
                    
                    switch nextAction {
                    case .exactSearch:
                        Task {
                            await estateService.exactSearch(keyword: estateService.fuzzyKeyword)
                        }
                        showExactSearchView = true
                    case .detail:
                        showDetail = true
                    }
                })
                Spacer().frame(height: 10)
                roomList
                Spacer()
            }
            .padding(.horizontal, 12)
            .background(Color.view.background)
            .setupNavigationBar(title: "搜索", {
                presentationMode.wrappedValue.dismiss()
            })
            .onChange(of: estateService.fuzzyKeyword) { newValue in
                if !disableSearch {
                    nextAction = .exactSearch
                    selectedRoomInfo = nil
                    search()
                }
                disableSearch = false
            }
            .onChange(of: areaTreeData) { _ in
                search()
            }
        }
    }
    
    private func search() {
        guard areaTreeData.provinceCode != 0 && areaTreeData.cityCode != 0 else {
            return
        }
        estateService.fuzzySearch(
            provinceCode: areaTreeData.provinceCode,
            cityCode: areaTreeData.cityCode)
    }
    
    private var liteInfoList: SearchResultList {
        estateService.fuzzySearchResult
    }
    
    @State private var selectedRoomInfo: SearchResult?
    
    @ViewBuilder
    private var roomList: some View {
        if liteInfoList.isEmpty {
            Image.main.emptyList
        } else {
            List {
                ForEach(liteInfoList, id: \.id) { info in
                    Button {
                        disableSearch = true
                        nextAction = .detail
                        estateService.fuzzyKeyword = info.roomName ?? ""
                        selectedRoomInfo = info
                    } label: {
                        roomItem(info: info)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    private func roomItem(info: SearchResult) -> some View {
        Text("\(info.roomName ?? "") - \(info.city ?? "") - \(info.estateTypeLabel ?? "")")
    }
    
    private var areaPicker: some View {
        Group {
            if areaTreeData.isEmpty {
                Text("请选择省市")
            } else {
                HStack {
                    Text(areaTreeData.provinceName)
                    Text(areaTreeData.cityName)
                }
            }
        }
        .plugUserAreaPicker(
            provinceCode: $areaTreeData.provinceCode,
            provinceName: $areaTreeData.provinceName,
            cityCode: $areaTreeData.cityCode,
            cityName: $areaTreeData.cityName,
            areaCode: $areaTreeData.areaCode,
            areaName: $areaTreeData.areaName,
            unitId: accountService.account?.unitId ?? 0
        )
        .onAppear {
            Task {
                guard let unitId = accountService.account?.unitId else {
                    Box.sendError("用户资料错误")
                    return
                }
                
                await areaTreeService.loadUserAreaTree(with: unitId)
                guard let tree = areaTreeService.userAreaTree else { return }
                
                areaTreeData.provinceCode = tree.provinceCode ?? 0
                areaTreeData.cityCode = tree.cityCode ?? 0
                if areaTreeData.provinceCode != 0 {
                    let pCode = "\(areaTreeData.provinceCode)"
                    areaTreeData.provinceName = tree.name(by: [pCode])
                    if areaTreeData.cityCode != 0 {
                        let cCode = "\(areaTreeData.cityCode)"
                        areaTreeData.cityName = tree.name(by: [pCode, cCode])
                    }
                }
            }
        }
    }
    
}

private enum NextAction {
    case exactSearch
    case detail
}

#Preview {
    NavigationView {
        FuzzySearchView()
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(EstateService.preview)
    }
}
