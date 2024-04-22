//
//  AreaPicker.swift
//  rps-ios
//
//  Created by serika on 2024/3/15.
//

import SwiftUI

enum AreaListType {
    case province, city, area
}

@MainActor
private class ViewModel: ObservableObject {
    @Published var provinceCode: String = ""
    @Published var provinceName: String = ""
    @Published var cityCode: String = ""
    @Published var cityName: String = ""
    @Published var areaCode: String = ""
    @Published var areaName: String = ""
    @Published private(set) var list = AreaListType.province
    @Published var treeNodes: [AreaTree] = []
    
    var bindingProvinceCode: Binding<Int>
    var bindingProvinceName: Binding<String>
    var bindingCityCode: Binding<Int>
    var bindingCityName: Binding<String>
    var bindingAreaCode: Binding<Int>
    var bindingAreaName: Binding<String>
    
    init(
        bindingProvinceCode: Binding<Int>,
        bindingProvinceName: Binding<String>,
        bindingCityCode: Binding<Int>,
        bindingCityName: Binding<String>,
        bindingAreaCode: Binding<Int>,
        bindingAreaName: Binding<String>
    ) {
        self.bindingProvinceCode = bindingProvinceCode
        self.bindingProvinceName = bindingProvinceName
        self.bindingCityCode = bindingCityCode
        self.bindingCityName = bindingCityName
        self.bindingAreaCode = bindingAreaCode
        self.bindingAreaName = bindingAreaName
    }

    
    func activate(list: AreaListType) {
        withAnimation(.linear(duration: 0.2)) {
            self.list = list
            refreshTreeNodes()
        }
    }
    
    private func refreshTreeNodes() {
        Task {
            treeNodes = await AreaTree.root.children(by: codeList)
        }
    }
    
    private var codeList: [String] {
        switch list {
        case .province: return []
        case .city: return [provinceCode]
        case .area: return [provinceCode, cityCode]
        }
    }
    
    func select(node: AreaTree) {
        switch list {
        case .province:
            provinceCode = node.code
            provinceName = node.name
            activate(list: .city)
        case .city:
            cityCode = node.code
            cityName = node.name
            activate(list: .area)
        case .area:
            areaCode = node.code
            areaName = node.name
            updateBinding()
        }
    }
    
    private func updateBinding() {
        self.bindingProvinceCode.wrappedValue = Int(provinceCode) ?? 0
        self.bindingProvinceName.wrappedValue = provinceName
        self.bindingCityCode.wrappedValue = Int(cityCode) ?? 0
        self.bindingCityName.wrappedValue = cityName
        self.bindingAreaCode.wrappedValue = Int(areaCode) ?? 0
        self.bindingAreaName.wrappedValue = areaName
    }
}

struct AreaPicker: View {
    @StateObject private var viewModel: ViewModel
    
    init(provinceCode: Binding<Int>,
         provinceName: Binding<String>,
         cityCode: Binding<Int>,
         cityName: Binding<String>,
         areaCode: Binding<Int>,
         areaName: Binding<String>,
         show: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(
            bindingProvinceCode: provinceCode,
            bindingProvinceName: provinceName,
            bindingCityCode: cityCode,
            bindingCityName: cityName,
            bindingAreaCode: areaCode,
            bindingAreaName: areaName
        ))
        self.show = show
    }
    
    private var show: Binding<Bool>
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("请选择所在地区")
                    .customText(size: 17, color: .text.gray3, weight: .bold)
                Spacer()
                Image.index.close
                    .onTapGesture {
                        show.wrappedValue = false
                    }
            }
            AreaTabView()
                .frame(maxWidth: .infinity, alignment: .leading)
            AreaListView()
        }
        .padding()
        .environmentObject(viewModel)
        .onAppear {
            viewModel.activate(list: .province)
        }
    }
}

private struct AreaTabView: View {
    @EnvironmentObject private var viewModel: ViewModel
    
    private var barOffset: CGFloat {
        switch viewModel.list {
        case .province: return -60
        case .city: return 0
        case .area: return 60
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                province
                city
                area
            }
            bar.offset(x: barOffset, y: 0)
        }
        .frame(height: 44)
    }
    
    private var province: some View {
        Button {
            viewModel.activate(list: .province)
        } label: {
            Group {
                if !viewModel.provinceCode.isEmpty {
                    nameLabel(text: viewModel.provinceName)
                } else {
                    placeholder(text: "省")
                }
            }
            .frame(width: 50)
        }
    }
    
    private var city: some View {
        Button {
            viewModel.activate(list: .city)
        } label: {
            Group {
                if !viewModel.cityCode.isEmpty {
                    nameLabel(text: viewModel.cityName)
                } else if !viewModel.provinceCode.isEmpty {
                    placeholder(text: "市")
                } else {
                    Color.white
                }
            }
            .frame(width: 50)
        }
    }
    
    private var area: some View {
        Button {
            viewModel.activate(list: .area)
        } label: {
            Group {
                if !viewModel.areaCode.isEmpty {
                    nameLabel(text: viewModel.areaName)
                } else if !viewModel.cityCode.isEmpty {
                    placeholder(text: "区")
                } else {
                    Color.white
                }
            }
            .frame(width: 50)
        }
    }
    
    private func nameLabel(text: String) -> some View {
        Text(text)
            .customText(size: 14, color: .text.gray3, weight: .bold)
    }
    
    private func placeholder(text: String) -> some View {
        Text("选择" + text)
            .customText(size: 14, color: .text.gray6)
    }
    
    private var bar: some View {
        Color.blue
            .frame(width: 50, height: 3)
            .clipShape(.rect(cornerRadius: 1.5))
    }
}

private struct AreaListView: View {
    @EnvironmentObject private var viewMode: ViewModel
    
    var body: some View {
        List(viewMode.treeNodes.indices, id: \.self) { idx in
            Text(viewMode.treeNodes[idx].name)
                .customText(size: 14, color: textColor(for: viewMode.treeNodes[idx]))
                .listRowInsets(.init(top: 0, leading: 1, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .onTapGesture {
                    viewMode.select(node: viewMode.treeNodes[idx])
                }
        }
        .listStyle(.plain)
    }
    
    private func textColor(for node: AreaTree) -> Color {
        [viewMode.provinceCode, viewMode.cityCode, viewMode.areaCode].contains(node.code) ? .blue : .text.gray3
    }
}

#Preview {
    Box.isPreview = true
    return AreaPicker(
        provinceCode: .constant(0),
        provinceName: .constant(""),
        cityCode: .constant(0),
        cityName: .constant(""),
        areaCode: .constant(0),
        areaName: .constant(""),
        show: .constant(false)
    )
}
