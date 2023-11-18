//
//  BannerView.swift
//  rps-ios
//
//  Created by serika on 2023/11/18.
//

import SwiftUI

struct BannerView: View {
    @State var selected = 1
    
    var body: some View {
        VStack {
            TabView(selection: $selected,
                    content:  {
                Text("Tab Content 1").tabItem { Text("Tab Label 1") }.tag(1)
                    .background(Color.red)
                Text("Tab Content 2").tabItem { Text("Tab Label 2") }.tag(0)
                    .background(Color.blue)
            })
            .tabViewStyle(PageTabViewStyle())
            Button("click") {
               selected = 1 - selected
            }
        }
        .background(Color.black)
    }
}

#Preview {
    BannerView()
}
