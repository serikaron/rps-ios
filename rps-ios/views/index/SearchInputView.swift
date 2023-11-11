//
//  SearchInputView.swift
//  rps-ios
//
//  Created by serika on 2023/11/10.
//

import SwiftUI

struct SearchInputView: View {
    @Binding var text: String
    var ocrAction: () -> Void = {}
    var searchAction: () -> Void = {}
    
    var body: some View {
        VStack {
            actionView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 28)
        .background(Color.hex("#E4EFFF"))
        .cornerRadius(8)
    }
    
    private var actionView: some View {
        HStack(spacing: 0) {
            Button {
                ocrAction()
            } label: {
                Image.index.searchOCR
            }
            Spacer().frame(width: 10)
            TextField("请输入物业名称或地址", text: $text)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer().frame(width: 10)
            Button {
                searchAction()
            } label: {
                Image.main.searchIcon
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 36)
        .background(Color.white)
        .cornerRadius(18)
    }
}

#Preview {
    SearchInputView(text: .constant("abc"))
}
