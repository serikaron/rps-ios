//
//  MainView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView() {
            IndexView()
                .tabItem {
                    Label("One", image: ("index-tab-button"))
                }.tag(1)
            Text("记录中心").tabItem {
                Label("Two", image: ("records-tab-button"))
            }.tag(2)
        }
    }
}

#Preview {
    MainView()
}
