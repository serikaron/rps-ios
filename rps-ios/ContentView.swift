//
//  ContentView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct ContentView: View {
    @StateObject var accountService = AccountService()
    @StateObject var areaTreeService = AreaTreeService()

    init () {
        Linkman.shared.showLog = true
//        Task {
//            await DictType.getDict()
//        }
        MapService.initMAMapKit()
        
        print("ContentView init")
    }
    
//    var body: some View {
//        DecorateView()
//    }
    
    var body: some View {
        ZStack {
            content
            LoadingView()
            ErrorView()
        }
    }
    
    private var content: some View {
        Group {
            if showMainView {
                MainView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(accountService)
        .environmentObject(areaTreeService)
    }
    
    private var showMainView: Bool {
        accountService.isLoggedIn && accountService.account != nil
    }
}

#Preview {
    ContentView()
}
