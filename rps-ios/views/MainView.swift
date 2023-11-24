//
//  MainView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var accountService: AccountService
    @StateObject var estateService = EstateService()
    @StateObject var tabService = TabService()
    
    
    var body: some View {
        ZStack {
            TabView(selection: $tabService.selectedTab) {
                ForEach(MainTabPage.allCases, id: \.self) { page in
                    page.page.tag(page)
                }
            }
            .environmentObject(accountService)
            .environmentObject(estateService)
            .environmentObject(tabService)

            if !tabService.isHidden {
                HStack {
                    ForEach(MainTabPage.allCases, id: \.self) { page in
                        Button {
                            tabService.selectedTab = page
                        } label: {
                            Group {
                                if (page == tabService.selectedTab) {
                                    VStack {
                                        page.buttonIconSelected
                                        Text(page.buttonTitle)
                                            .customText(size: 10, color: .main)
                                            .lineLimit(1)
                                    }
                                } else {
                                    VStack {
                                        page.buttonIcon
                                        Text(page.buttonTitle)
                                            .customText(size: 10, color: .black)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .background(
                    Color.white
                        .cornerRadius(8)
                        .shadow(color: .hex("#A4ADBC").opacity(0.2), radius: 10)
                        .frame(height: 49+34)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea()
                )
            }
        }
        .onAppear {
            Task {
                await DictType.getDict()
            }
        }
    }
}

private extension MainTabPage {
    
    var tag: Int {
        switch self {
        case .index: return 1
        case .record: return 2
        case .cs: return 3
        case .me: return 4
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .index: return "首页"
        case .record: return "记录中心"
        case .cs: return "在线客服"
        case .me: return "我的"
        }
    }
    
    var buttonIconSelected: Image {
        switch self {
        case .index: return Image.main.indexTabIconSelected
        case .record: return Image.main.recordTabIconSelected
        case .cs: return Image.main.csTabIconSelected
        case .me: return Image.main.meTabIconSelected
        }
    }
    
    var buttonIcon: Image {
        switch self {
        case .index: return Image.main.indexTabIcon
        case .record: return Image.main.recordTabIcon
        case .cs: return Image.main.csTabIcon
        case .me: return Image.main.meTabIcon
        }
    }
    
    var page: some View {
        switch self {
        case .index: return IndexView().earseToAnyView()
        case .record: return RecordsCenterView().earseToAnyView()
        case .cs: return CustomServiceView().earseToAnyView()
        case .me: return MeView().earseToAnyView()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AccountService())
}
