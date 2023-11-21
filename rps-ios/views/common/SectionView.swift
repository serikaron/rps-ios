//
//  SectionView.swift
//  rps-ios
//
//  Created by serika on 2023/11/20.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title).headerText()
            Spacer().frame(height: 20)
            VStack(spacing: 0, content: {
                content()
            })
        }
        .sectionStyle()
    }
}

#Preview {
    SectionView(title: "Section") {
    }
        .frame(maxHeight: .infinity)
        .background(Color.black)
}
