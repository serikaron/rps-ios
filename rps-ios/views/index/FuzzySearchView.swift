//
//  FuzzySearchView.swift
//  rps-ios
//
//  Created by serika on 2023/11/10.
//

import SwiftUI

struct FuzzySearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    
    @State private var nextAction: NextAction = .exactSearch
    @State private var showExactSearchView = false
    @State private var disableSearch = false
    
    @State private var showDetail = false
    
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
                    estateService.fuzzySearch()
                }
                disableSearch = false
            }
        }
    }
    
    private var searchRoomTask: Task<Void, Never>?
    
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
        Text(info.roomName ?? "")
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
