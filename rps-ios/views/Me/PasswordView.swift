//
//  PasswordView.swift
//  rps-ios
//
//  Created by serika on 2023/11/23.
//

import SwiftUI

struct PasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var accountService: AccountService
    
    @State private var orgPassword = ""
    @State private var newPassword = ""
    @State private var newPassword2 = ""
    
    var body: some View {
        VStack {
            VStack {
                itemView(title: "原密码", placeholder: "请输入原密码", binding: $orgPassword)
                    .textContentType(.password)
                Divider()
                itemView(title: "新密码", placeholder: "请输入新密码", binding: $newPassword)
                    .textContentType(.password)
                Divider()
                itemView(title: "重复新密码", placeholder: "请再次输入新密码", binding: $newPassword2)
                    .textContentType(.newPassword)
            }
            .sectionStyle()
            Spacer()
            Button {
                Task {
                    let success = await accountService.resetPassword(orgPassword: orgPassword, newPassword: newPassword, newPassword2: newPassword2)
                    if success {
                        Box.sendError("修改成功")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } label: {
                Text("保存")
                    .customText(size: 16, color: .white)
                    .frame(width: 260, height: 40)
                    .background(Color.main)
                    .cornerRadius(10)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.view.background)
        .setupNavigationBar(title: "修改密码") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func itemView(title: String, placeholder: String, binding: Binding<String>) -> some View {
        HStack {
            Text(title).itemTitle()
            SecureField(placeholder, text: binding)
                .itemContent()
                .multilineTextAlignment(.trailing)
        }
        .frame(height: 36)
    }
}

#Preview {
    PasswordView()
}
