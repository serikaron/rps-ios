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
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
                    Group {
                        if let countDown = accountService.smsCountDown {
                            Text("\(countDown)秒后重试")
                        } else {
                            Text("获取验证码")
                                .onTapGesture {
                                    Task {
                                        await accountService.getSms(phone: phone)
                                    }
                                }
                        }
                    }
                        .onReceive(timer, perform: { _ in
                            accountService.smsCount()
                        })
                        .customText(size: 14, color: .main)
                        .padding(.trailing, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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
    @State private var registerCode: String = ""
    @State private var provinceCode: Int = 0
    @State private var cityCode: Int = 0
    @State private var areaCode: Int = 0
    @State private var provinceName: String = ""
    @State private var cityName: String = ""
    @State private var areaName: String = ""

    @State private var areaTree = AreaTree(code: "", name: "", children: [])
    
    private var address: String{
        "\(provinceName)\(cityName)\(areaName)"
    }

    private let rightWidth: CGFloat = 178
    
    var body: some View {
        VStack {
            Spacer().frame(height: 100)
            sheet
            Spacer()
            HStack {
                Button {
                    Task {
                        let success = await accountService.register(
                            account: account, name: name, gender: gender, birthday: birthday,
                            registerCode: registerCode,
                            company: company, department: department, position: position,
                            phone: phone, mobile: mobile, email: email, contact: contact,
                            provinceCode: provinceCode, cityCode: cityCode, areaCode: areaCode,
                            proviceName: provinceName, cityName: cityName, areaName: areaName)
                        if success {
                            viewType = .login
                        }
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
        .onAppear {
            Task {
                areaTree = await AreaTree.root
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private var sheet: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 35)
                Text.activated(text: "注册帐户")
                Spacer().frame(height: 35)
                VStack(spacing: 10) {
                    formInput(title: "登录名", isRequired: true, text: $account)
                    formInput(title: "姓名", isRequired: true, text: $name)
                    formItem(title: "性别", isRequired: false) {
                        HStack {
                            radioButton(gender: .female)
                            radioButton(gender: .male)
                        }
                    }
                    formItem(title: "生日", isRequired: false) {
                        HStack {
                            Text(birthday.isEmpty ? "请选择" : birthday)
                                .customText(size: 14, color: birthday.isEmpty ? .text.grayCD : .text.gray3)
                                .frame(height: 30)
                            Spacer()
                            Image.main.calendarIcon
                        }
                        .background(Color.white)
                        .padding(.horizontal, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.hex("#CDCDCD"))
                        )
                        .plugDatePicker(str: $birthday)
                    }
                    formInput(title: "注册码", isRequired: true, text: $registerCode)
                    formInput(title: "所在单位", isRequired: true, text: $company)
                    formInput(title: "所在部门", isRequired: true, text: $department)
                    formInput(title: "职务", isRequired: true, text: $position)
                    formInput(title: "办公电话", isRequired: false, text: $phone)
                        .keyboardType(.numberPad)
                    formInput(title: "手机", isRequired: true, text: $mobile)
                        .keyboardType(.numberPad)
                    formInput(title: "电子邮箱", isRequired: false, text: $email)
                    formInput(title: "QQ/MSN", isRequired: false, text: $contact)
                    formItem(title: "所在区域", isRequired: true) { addressPicker }
                }
                Spacer().frame(height: 35)
            }
        }
        .background(SheetBackground())
    }
    
    private func formItem(title: String, isRequired: Bool, _ content: () -> some View) -> some View {
        HStack(spacing: 0) {
            if (isRequired) {
                Text("*")
                    .customText(size: 14, color: .red)
            }
            Text.deactivated(text: "\(title)：")
            Spacer()
            content()
                .frame(width: rightWidth)
        }
        .padding(.leading, 41)
        .padding(.trailing, 24)
        .frame(height: 30)
    }
    
    private func formInput(title: String, isRequired: Bool, text: Binding<String>) -> some View {
        formItem(title: title, isRequired: isRequired) { inputText(text: text) }
    }
    
    private func inputText(text: Binding<String>) -> some View {
        TextField("请输入", text: text)
            .customText(size: 14, color: .text.gray3)
            .frame(height: 30)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.hex("#CDCDCD"))
            )
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
    
    private var addressPicker: some View {
        Menu {
            ForEach(areaTree.children, id: \.code) { province in
                Menu {
                    ForEach(province.children, id: \.code) { city in
                        Menu {
                            ForEach(city.children, id: \.code) { area in
                                Button {
                                    provinceCode = Int(province.code) ?? 0
                                    provinceName = province.name
                                    cityCode = Int(city.code) ?? 0
                                    cityName = city.name
                                    areaCode = Int(area.code) ?? 0
                                    areaName = area.name
                                } label: {
                                    Text(area.name)
                                }
                            }
                        } label: {
                            Text(city.name)
                        }
                    }
                } label: {
                    Text(province.name)
                }
            }
        } label: {
            HStack {
                Text(address.isEmpty ? "请选择" : address)
                    .customText(size: 14, color: address.isEmpty ? .text.grayCD : .text.gray3)
                Spacer()
                Image.main.arrowIconRight
            }
            .frame(height: 30)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.hex("#CDCDCD"))
            )
        }
    }
}

#Preview("注册") {
    RegisterView(viewType: .constant(.login))
        .environmentObject(AccountService.preview)
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
        .environmentObject(AccountService.preview)
}
