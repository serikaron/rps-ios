//
//  ContentView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct ContentView: View {
    @StateObject var accountService = AccountService()
    
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
            if accountService.isLoggedIn {
                MainView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(accountService)
    }
    
//    private var content: some View {
//        if Account.isLoggedIn {
//            MainView().earseToAnyView()
//        } else {
//            LoginView().earseToAnyView()
//        }
//    }
}

#Preview {
    ContentView()
}
