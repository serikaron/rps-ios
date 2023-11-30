//
//  MeInfoView.swift
//  rps-ios
//
//  Created by serika on 2023/11/23.
//

import SwiftUI

struct MeInfoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var accountService: AccountService
    
    private var account: Account? {
        accountService.account
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LinearGradient(colors: [sideColor, centerColor, centerColor, sideColor], startPoint: .bottomLeading, endPoint: .topTrailing)
                    .frame(height: 255)
                    .overlay(
                        VStack(spacing: 0) {
                            Image.me.avatar
                            Spacer().frame(height: 20)
                            Text(account?.nickname ?? "")
                                .customText(size: 16, color: .text.gray3, weight: .medium)
                        }.padding(.bottom, 30),
                        alignment: .bottom
                    )
                    .frame(maxHeight: .infinity, alignment: .top)
                
                content
            }
        }
        .background(Color.view.background)
        .setupNavigationBar(title: "我的") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var content: some View {
        VStack(spacing: 10) {
            VStack {
                itemView(title: "登录名", content: account?.clientName ?? "")
                Divider()
                itemView(title: "身份类别", content: account?.position ?? "")
                Divider()
                itemView(title: "单位", content: account?.placeUnit ?? "")
                Divider()
                itemView(title: "部门职务", content: account?.placeOrganization ?? "")
                Divider()
                itemView(title: "显示状态", content: account?.status.label ?? "")
                Divider()
                itemView(title: "有效期", content: account?.date ?? "")
            }.sectionStyle()
            
            VStack {
                itemView(title: "性别", content: account?.gender.label ?? "")
                Divider()
                itemView(title: "出生年月", content: account?.birthday ?? "")
                Divider()
                itemView(title: "手机", content: account?.phone ?? "")
                Divider()
                itemView(title: "邮箱", content: account?.email ?? "")
                Divider()
                itemView(title: "办公电话", content: account?.workPhone ?? "")
                Divider()
                NavigationLink {
                    MeEditView()
                } label: {
                    Text("修改信息").itemTitle().frame(height: 36)
                }
            }.sectionStyle()
        }
        .padding(.vertical, 10)
        .padding(.bottom, 20)
    }
    
    private var sideColor: Color {
        .black.opacity(0.25)
    }
    
    private var centerColor: Color {
        .black.opacity(0.08)
    }
    
    private func itemView(title: String, content: String) -> some View {
        HStack {
            Text(title).itemTitle()
            Spacer()
            Text(content).itemContent()
        }
        .frame(height: 36)
    }
}

#Preview {
    NavigationView {
        MeInfoView()
            .environmentObject(AccountService.preview)
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MeEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var accountService: AccountService
    
    private struct EditAccount {
        var gender: Gender = .male
        var birthday: String = ""
        var phone: String = ""
        var email: String = ""
        var workPhone: String = ""
    }
    @State private var editAccount = EditAccount()
    
    var body: some View {
        VStack {
            input
            Spacer()
            Text("保存")
                .customText(size: 16, color: .white)
                .frame(width: 260, height: 40)
                .background(Color.main)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    Task {
                        let birthday = editAccount.birthday.toDate()?.toString(format: "YYYY-MM") ?? ""
                        print(birthday)
                        await accountService.updateInfo(gender: editAccount.gender, phone: editAccount.phone, birthday: birthday, email: editAccount.email, workPhone: editAccount.workPhone)
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        .padding(.top, 10)
        .padding(.bottom)
        .background(Color.view.background)
        .setupNavigationBar(title: "修改信息", {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            if let account = accountService.account {
                editAccount.gender = account.gender
                editAccount.birthday = account.birthday
                editAccount.phone = account.phone
                editAccount.workPhone = account.workPhone
                editAccount.email = account.email
            }
        }
    }
    
    private var input: some View {
        VStack {
            HStack {
                Text("性别").itemTitle()
                Spacer()
                HStack(spacing: 20) {
                    HStack {
                        editAccount.gender == .female ? Image.me.radioColor : Image.me.radioGray
                        Text("女")
                    }
                    .onTapGesture { editAccount.gender = .female }
                    HStack {
                        editAccount.gender == .male ? Image.me.radioColor : Image.me.radioGray
                        Text("男")
                    }
                    .onTapGesture { editAccount.gender = .male }
                }
                .itemContent()
            }.frame(height: 36)
            Divider()
            HStack {
                Text("出生年月").itemTitle()
                Spacer()
                Text(editAccount.birthday.isEmpty ? "请选择" : editAccount.birthday)
                    .foregroundColor(editAccount.birthday.isEmpty ? .text.grayCD : .text.gray3)
                    .itemContent()
                    .overlay(
                        DatePicker("",
                            selection: Binding(
                                get: { editAccount.birthday.toDate() ?? Date() },
                                set: { editAccount.birthday = $0.toString() }),
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .blendMode(.destinationOver)
                    )
            }.frame(height: 36)
            Divider()
            HStack {
                Text("手机").itemTitle()
                Spacer()
                TextField("请输入", text: $editAccount.phone)
                    .itemContent()
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }.frame(height: 36)
            Divider()
            HStack {
                Text("邮箱").itemTitle()
                Spacer()
                TextField("请输入", text: $editAccount.email)
                    .itemContent()
                    .multilineTextAlignment(.trailing)
            }.frame(height: 36)
            Divider()
            HStack {
                Text("办公手机").itemTitle()
                Spacer()
                TextField("请输入", text: $editAccount.workPhone)
                    .itemContent()
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }.frame(height: 36)
        }
        .sectionStyle()
    }
}

#Preview("edit") {
    NavigationView {
        MeEditView()
            .environmentObject(AccountService.preview)
    }
}

