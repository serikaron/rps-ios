//
//  LoginView.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    @EnvironmentObject var accountService: AccountService
    
    @State private var viewType: ViewType = .login
    
    var body: some View {
        Image.onboarding.background
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .overlay(content, alignment: .top)
            .environmentObject(accountService)
    }
    
    private var content: some View {
        switch viewType {
        case .login:
            return LoginView(viewTtype: $viewType).earseToAnyView()
        case .register:
            return RegisterView(viewType: $viewType).earseToAnyView()
        }
    }
}

private enum ViewType {
    case login, register
}

// MARK: - LoginView

private struct LoginView: View {
    @EnvironmentObject var accountService: AccountService
    @Binding var viewTtype: ViewType
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 143)
            Image.onboarding.logo
            Spacer().frame(height: 41)
            sheet
        }
    }
    
    @State private var sheetType: Sheet = .password
    
    private var sheet: some View {
        sheetContent
            .background(SheetBackground())
            .padding(.horizontal, 44)
    }
    
    private var sheetContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            HStack {
                ForEach(Sheet.allCases, id: \.self) { type in
                    Button {
                        sheetType = type
                    } label: {
                        if (type == sheetType) {
                            Text.activated(text: type.text)
                        } else {
                            Text.deactivated(text: type.text)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer().frame(height: 30)
            switch sheetType {
            case .password:
                passwordForm
            case .phone:
                phoneForm
            }
            Spacer().frame(height: 18)
        }
        .padding(.horizontal, 27)
    }
    
    @State private var account: String = ""
    @State private var password: String = ""
    private var passwordForm: some View {
        VStack {
            OnboardingInput(
                icon: Image.onboarding.accountIcon,
                placeholder: "请输入帐号",
                text: $account,
                secure: false
            )
            .textContentType(.username)
            Spacer().frame(height: 20)
            OnboardingInput(
                icon: Image.onboarding.passwordIcon,
                placeholder: "请输入密码",
                text: $password,
                secure: true
            )
            .textContentType(.password)
            Spacer().frame(height: 30)
            Button {
                Task {
                    await accountService.login(username: account, password: password)
                }
            } label: {
                loginButtonLabel
            }
            Spacer().frame(height: 16)
            Button {
                viewTtype = .register
            } label: {
                Text("申请注册")
                    .customText(size: 14, color: .text.gray6)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    @State private var phone: String = ""
    @State private var code: String = ""
    private var phoneForm: some View {
        VStack {
            OnboardingInput(
                icon: Image.onboarding.phoneIcon,
                placeholder: "请输入手机号",
                text: $phone,
                secure: false
            )
            .textContentType(.telephoneNumber)
            Spacer().frame(height: 20)
            OnboardingInput(
                icon: Image.onboarding.codeIcon,
                placeholder: "请输入验证码",
                text: $code,
                secure: false
            )
            .textContentType(.oneTimeCode)
                .overlay (
                    Text("获到验证码")
                        .customText(size: 14, color: .main)
                        .padding(.trailing, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .onTapGesture {
                            Task {
                                await accountService.getSms(phone: phone)
                            }
                        }
                )
            Spacer().frame(height: 30)
            Button {
                Task {
                    await accountService.login(phone: phone, smsCode: code)
                }
            } label: {
                loginButtonLabel
            }
            Spacer().frame(height: 16)
            Button {
                viewTtype = .register
            } label: {
                Text("申请注册")
                    .customText(size: 14, color: .text.gray6)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private var loginButtonLabel: some View {
        Text("登录")
            .customText(size: 18, color: .white)
            .frame(height: 49)
            .frame(maxWidth: .infinity)
            .background(Color.main)
            .cornerRadius(4)
    }
}

private enum Sheet: CaseIterable {
    case password, phone
    
    var text: String {
        switch self {
        case .password: return "系统登录"
        case .phone: return "手机号登录"
        }
    }
}

// MARK: - RegisterView

private struct RegisterView: View {
    @EnvironmentObject var accountService: AccountService
    @Binding var viewType: ViewType
    
    @State private var account: String = ""
    @State private var name: String = ""
    @State private var gender: Gender = .female
    @State private var birthday: String = ""
    @State private var company: String = ""
    @State private var department: String = ""
    @State private var position: String = ""
    @State private var phone: String = ""
    @State private var mobile: String = ""
    @State private var email: String = ""
    @State private var contact: String = ""
    @State private var address: String = ""
    
    private let rightWidth: CGFloat = 178
    
    var body: some View {
        VStack {
            Spacer().frame(height: 100)
            sheet
            Spacer()
            HStack {
                Button {
                    Task {
                        await accountService.register(
                            account: account, name: name, gender: gender, birthday: birthday,
                            company: company, department: department, position: position,
                            phone: phone, mobile: mobile, email: email, contact: contact,
                            address: address)
                    }
                } label: {
                    buttonLabel(text: "保存")
                }
                Spacer()
                Button {
                    viewType = .login
                } label: {
                    buttonLabel(text: "取消")
                }
            }
            .padding(.horizontal, 26)
            Spacer().frame(height: 52)
        }
        .padding(.horizontal, 28)
    }
    
    private var sheet: some View {
        VStack {
            Spacer().frame(height: 35)
            Text.activated(text: "注册帐户")
            Spacer().frame(height: 35)
            VStack(spacing: 10) {
                formInput(title: "登录名", text: $account)
                formInput(title: "姓名", text: $name)
                formItem(title: "性别") {
                    HStack {
                        radioButton(gender: .female)
                        radioButton(gender: .male)
                    }
                }
                formItem(title: "生日") {
                    inputText(text: $birthday)
                }
                formInput(title: "所在单位", text: $company)
                formInput(title: "所在部门", text: $department)
                formInput(title: "职务", text: $position)
                formInput(title: "办公电话", text: $phone)
                formInput(title: "手机", text: $mobile)
                formInput(title: "电子邮箱", text: $email)
                formInput(title: "QQ/MSN", text: $contact)
                formInput(title: "所在区域", text: $address)
            }
            Spacer().frame(height: 35)
        }
        .background(SheetBackground())
    }
    
    private func formItem(title: String, _ content: () -> some View) -> some View {
        HStack {
            Text.deactivated(text: "\(title)：")
            Spacer()
            content()
                .frame(width: rightWidth)
        }
        .padding(.leading, 41)
        .padding(.trailing, 24)
        .frame(height: 30)
    }
    
    private func formInput(title: String, text: Binding<String>) -> some View {
        formItem(title: title) { inputText(text: text) }
    }
    
    private func inputText(text: Binding<String>) -> some View {
        TextField("请输入", text: text)
            .padding(.horizontal, 16)
            .cornerRadius(4)
            .border(Color.hex("#CDCDCD"))
    }
    
    private func radioButton(gender: Gender) -> some View {
        Button {
            self.gender = gender
        } label: {
            HStack {
                if self.gender == gender {
                    Image.onboarding.selectedIcon
                } else {
                    Image.onboarding.deselectedIcon
                }
                Text.deactivated(text: gender.label)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func buttonLabel(text: String) -> some View {
        Text(text)
            .frame(width: 109, height: 40)
            .customText(size: 14, color: .white)
            .background(Color.main)
            .cornerRadius(4)
    }
}

// MARK: - helper

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
    var icon: Image
    var placeholder: String
    @Binding var text: String
    var secure: Bool
    
    var body: some View {
        HStack {
            icon
            Spacer().frame(width: 24)
            if secure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.inputBg)
        .cornerRadius(4)
    }
}

private struct SheetBackground: View {
    var body: some View {
        Color.white
            .cornerRadius(8)
            .shadow(color: .shadow, radius: 10)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AccountService())
}
