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
            ZStack {
                VStack(spacing: 0) {
                    Spacer().frame(height: 20)
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
                .background(Color.view.background)
                .padding(.top, 255)
                .ignoresSafeArea()
                
                LinearGradient(colors: [sideColor, centerColor, centerColor, sideColor], startPoint: .bottomLeading, endPoint: .topTrailing)
                    .frame(height: 255)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 20)
                    Image.me.avatar
                    Spacer().frame(height: 20)
                    Text(account?.nickname ?? "")
                        .customText(size: 16, color: .text.gray3, weight: .medium)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
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
