//
//  LoadingView.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import SwiftUI

struct LoadingView: View {
    @State private var show = false
    
    var body: some View {
        Group {
            if show {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .main))
                    .background(
                        Color.black
                            .opacity(0.15)
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                    )
            }
        }
        .onReceive(Box.shared.loadingSubject) { loading in
//            print("loading: \(loading)")
            show = loading
        }
    }
}

#Preview {
    LoadingView()
}
