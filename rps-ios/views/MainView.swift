//
//  MainView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var accountService: AccountService
    
    @State private var selectedTab = 1
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(Page.allCases, id: \.self) { page in
                    page.page.tag(page.tag)
                }
            }
            .environmentObject(accountService)
            
            HStack {
                ForEach(Page.allCases, id: \.self) { page in
                    Button {
                        selectedTab = page.tag
                    } label: {
                        Group {
                            if (page.tag == selectedTab) {
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
        .onAppear {
            Task {
                await DictType.getDict()
            }
        }
    }
}

private enum Page: CaseIterable {
    case index, record
    
    var tag: Int {
        switch self {
        case .index: return 1
        case .record: return 2
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .index: return "首页"
        case .record: return "记录中心"
        }
    }
    
    var buttonIconSelected: Image {
        switch self {
        case .index: return Image.main.indexTabIconSelected
        case .record: return Image.main.recordTabIconSelected
        }
    }
    
    var buttonIcon: Image {
        switch self {
        case .index: return Image.main.indexTabIcon
        case .record: return Image.main.recordTabIcon
        }
    }
    
    var page: some View {
        switch self {
        case .index: return IndexView().earseToAnyView()
        case .record: return Text("记录中心").earseToAnyView()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AccountService())
}
