//
//  MeView.swift
//  rps-ios
//
//  Created by serika on 2023/11/23.
//

import SwiftUI

struct MeView: View {
    @EnvironmentObject var accountService: AccountService
    
    private var account: Account? {
        accountService.account
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                LinearGradient(colors: [sideColor, centerColor, centerColor, sideColor], startPoint: .bottomLeading, endPoint: .topTrailing)
                    .frame(height: 255)
                    .overlay(
                        VStack(spacing: 0) {
                            NavigationLink {
                                MeInfoView()
                            } label: {
                                Image.me.avatar
                            }
                            Spacer().frame(height: 20)
                            Text(account?.nickname ?? "")
                                .customText(size: 16, color: .text.gray3, weight: .medium)
                        }.padding(.bottom, 30),
                        alignment: .bottom
                    )
                Spacer().frame(height: 20)
                content
           }
            .background(Color.view.background)
//            .ignoresSafeArea()
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            NavigationLink {
                MessageView()
            } label: {
                HStack {
                    Image.me.message
                    Text("我的邮箱")
                        .customText(size: 14, color: .text.gray3)
                    Spacer()
                    Image.main.arrowIconRight
                }
                .padding(.horizontal, 16)
                .frame(height: 60)
                .background(Color.white)
            }
            Spacer().frame(height: 10)
            NavigationLink {
                PasswordView()
            } label: {
                HStack {
                    Image.me.password
                    Text("修改密码")
                        .customText(size: 14, color: .text.gray3)
                    Spacer()
                    Image.main.arrowIconRight
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color.white)
            Spacer()
            Button {
                Task {
                    await accountService.logout()
                }
            } label: {
                Text("退出登录")
                    .customText(size: 16, color: .white)
                    .frame(width: 260, height: 40)
                    .background(Color.hex("#F04C4C"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 100)
            }
        }
    }
    
    private var sideColor: Color {
        .black.opacity(0.25)
    }
    
    private var centerColor: Color {
        .black.opacity(0.08)
    }
}

#Preview {
    MeView()
        .environmentObject(AccountService.preview)
}
