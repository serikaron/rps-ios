//
//  BuildingsView.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import SwiftUI

struct BuildingsView: View {
    @EnvironmentObject var estateService: EstateService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let comId: Int
    let estateType: String
    
    @State private var buildings: Buildings = []
    @State private var allLoaded = false
    @State private var pageNum = 1
    private let pageSize = 10
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack() {
                    ForEach(Array(zip(buildings.indices, buildings)), id: \.0) { idx, building in
                        view(for: building)
                            .onAppear {
                                if (idx == buildings.count - 2) {
                                    loadBuildings()
                                }
                            }
                    }
                }
                .padding(.horizontal, 12)
                .background(Color.white)
            }
            .padding(.top, 20)
            .background(Color.view.background)
        }
        .onAppear {
            loadBuildings()
        }
        .setupNavigationBar(title: "楼幢列表") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func view(for building: Building) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Color.main
                        .frame(width: 4, height: 16)
                    Text("\(building.completionDate)建筑")
                        .customText(size: 13, color: .text.gray3)
                }
                Spacer().frame(height: 10)
                HStack {
                    Text("\(building.name)")
                        .customText(size: 18, color: .text.gray3, weight: .bold)
                    Text("总层：\(building.height)")
                        .customText(size: 12, color: .text.gray3)
                }
                Spacer().frame(height: 10)
                Text("楼幢别名：\(building.alias)")
                    .customText(size: 14, color: .text.gray3)
            }
            Spacer()
            Text("查看户信息")
                .customText(size: 13, color: .main)
                .frame(width: 87, height: 38)
                .background(Color.hex("#D9E3FF"))
                .cornerRadius(6)
        }
        .frame(height: 110)
        .padding(.horizontal, 20)
    }
    
    private func loadBuildings() {
        if allLoaded { return }
        Task {
            let rsp = await estateService.getBuildings(comId: comId, estateType: estateType, pageSize: pageSize, pageNum: pageNum)
            print("loadBuildings rsp: \(rsp)")
            buildings.append(contentsOf: rsp.buildings)
            allLoaded = buildings.count >= rsp.total || pageSize > rsp.size
            pageNum += 1
        }
    }
}

#Preview {
    Linkman.shared.standalone = true
    Box.setToken("")
    return NavigationView {
        BuildingsView(comId: 1, estateType: "singleApartment")
            .environmentObject(EstateService.preview)
            .navigationBarTitleDisplayMode(.inline)
    }
}
