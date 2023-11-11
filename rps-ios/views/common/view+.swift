//
//  font.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

struct CustomText: ViewModifier {
    let size: CGFloat
    let color: Color?
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}
extension View {
    func customText(size: CGFloat, color: Color?, weight: Font.Weight = .regular) -> some View {
        modifier(CustomText(size: size, color: color, weight: weight))
    }
}

extension View {
    func earseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct SetupNavigationBar: ViewModifier {
    let title: String
    let backAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        backAction()
                    } label: {
                        Image.main.arrowIcon
                    }
                }
            }
    }
}

extension View {
    func setupNavigationBar(title: String, _ backAction: @escaping () -> Void) -> some View {
        modifier(SetupNavigationBar(title: title, backAction: backAction))
    }
}

