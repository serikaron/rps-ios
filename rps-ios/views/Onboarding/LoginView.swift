//
//  LoginView.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        Image.onboarding.background
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .overlay(content, alignment: .top)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 143)
            Image.onboarding.logo
            Spacer().frame(height: 41)
            sheet
        }
    }
    
    @State private var selectedType: LoginType = .password
    private var sheet: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                HStack {
                    ForEach(LoginType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            if (type == selectedType) {
                                Text.activated(text: type.text)
                            } else {
                                Text.deactivated(text: type.text)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Spacer().frame(height: 30)
                switch selectedType {
                case .password:
                    passwordForm
                case .phone:
                    phoneForm
                }
                Spacer().frame(height: 18)
            }
            .padding(.horizontal, 27)
            .background(
                Color.white
                    .shadow(color: .shadow, radius: 10)
            )
        }
        .padding(.horizontal, 44)
    }
    
    @State private var account: String = ""
    @State private var password: String = ""
    private var passwordForm: some View {
        VStack {
            OnboardingInput(placeholder: "请输入帐号", text: $account)
            Spacer().frame(height: 20)
            OnboardingInput(placeholder: "请输入密码", text: $password)
            Spacer().frame(height: 30)
            loginButton
            Spacer().frame(height: 16)
            Text("申请注册")
                .customText(size: 14, color: .text.gray6)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    @State private var phone: String = ""
    @State private var code: String = ""
    private var phoneForm: some View {
        VStack {
            OnboardingInput(placeholder: "请输入手机号", text: $phone)
            Spacer().frame(height: 20)
            OnboardingInput(placeholder: "请输入验证码", text: $code)
                .overlay (
                    Text("获到验证码")
                        .customText(size: 14, color: .main)
                    , alignment: .trailing
                )
            Spacer().frame(height: 30)
            loginButton
            Spacer().frame(height: 16)
            Text("申请注册")
                .customText(size: 14, color: .text.gray6)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    private var loginButton: some View {
        Text("登录")
            .customText(size: 18, color: .white)
            .frame(height: 49)
            .frame(maxWidth: .infinity)
            .background(Color.main)
            .cornerRadius(4)
    }
}

private enum LoginType: CaseIterable {
    case password, phone
    
    var text: String {
        switch self {
        case .password: return "系统登录"
        case .phone: return "手机号登录"
        }
    }
}

private extension Text {
    static func activated(text: String) -> some View {
        Text(text).customText(size: 18, color: .text.gray3, weight: .medium)
    }
    
    static func deactivated(text: String) -> some View {
        Text(text).customText(size: 14, color: .text.gray6)
    }
}

private extension Color {
    static var shadow: Color { .hex("#7CB0FE").opacity(0.2) }
    static var inputBg: Color { .hex("#F0F2F6") }
}

private struct OnboardingInput: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image.onboarding.accountIcon
            Spacer().frame(width: 24)
            TextField(placeholder, text: $text)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.inputBg)
        .cornerRadius(4)
    }
}

#Preview {
    LoginView()
}
