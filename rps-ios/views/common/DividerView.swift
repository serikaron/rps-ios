//
//  DividerView.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct DividerView: View {
    let size: CGSize
    var color: Color = .view.divider
    
    var body: some View {
        return color
            .frame(width: size.width, height: size.height)
    }
}

struct VerticalDivider: View {
    let length: CGFloat
    
    var body: some View {
        return DividerView(size: CGSize(width: 1, height: length))
    }
}

struct HorizontalDivider: View {
    let length: CGFloat
    
    var body: some View {
        return DividerView(size: CGSize(width: length, height: 1))
    }
}

#Preview {
    DividerView(size: CGSize(width: 1, height: 10), color: .red)
}
