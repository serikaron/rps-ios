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


struct SectionStyleModifier: ViewModifier {
    let vPadding: Double
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, vPadding)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 12)
    }
}
extension View {
    func sectionStyle(vPadding: Double = 20) -> some View {
        modifier(SectionStyleModifier(vPadding: vPadding))
    }
}

struct HeaderTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .customText(size: 16, color: .text.gray3, weight: .medium)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
extension View {
    func headerText() -> some View {
        modifier(HeaderTextModifier())
    }
    func itemTitle() -> some View {
        modifier(CustomText(size: 14, color: .text.gray3, weight: .regular))
    }
    func itemContent() -> some View {
        modifier(CustomText(size: 14, color: .text.gray6, weight: .regular))
    }
    func itemPlaceholder() -> some View {
        modifier(CustomText(size: 14, color: .text.grayCD, weight: .regular))
    }
}
