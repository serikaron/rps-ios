//
//  ContentView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            if Account.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
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
