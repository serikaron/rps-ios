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
//        Box.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJycHNfdXNlcjo0MCIsInJuU3RyIjoiQlFpb0p2WUJkaTBzNlRvQ1NtMlg1RmIxRHZuV3NOZUMiLCJ1c2VySWQiOjQwfQ.38Hkz9cSo2tuMGHGilzrlMr3VRgrbUOrLjldbiKUpc8")
    }
    
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
