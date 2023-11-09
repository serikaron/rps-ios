//
//  ErrorView.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import SwiftUI

struct ErrorView: View {
    @StateObject private var service = ErrorService()
    
    @State private var alpha: Double = 0
    
    var body: some View {
        Text(service.errorMessage ?? "")
            .padding(15)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(15)
            .opacity(alpha)
            .onReceive(service.$showError) { show in
                withAnimation {
                    alpha = show ? 1 : 0
                }
            }
    }
}

#Preview {
    ErrorView()
}

