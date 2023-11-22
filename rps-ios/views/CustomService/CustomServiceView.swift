//
//  CustomServiceView.swift
//  rps-ios
//
//  Created by serika on 2023/11/22.
//

import SwiftUI

struct CustomServiceView: View {
    @State private var compList = [CSComp]()
    
    var body: some View {
        ZStack {
            Image.cs.bg
                .resizable()
            VStack(spacing: 0) {
                VStack {
                    Text("点击可查看二维码")
                    Text("添加在线客服")
                }
                .customText(size: 22, color: .white)
                .frame(height: 113)
                ScrollView {
                    ForEach(Array(zip(compList.indices, compList)), id: \.0) { idx, comp in
                        CompView(comp: $compList[idx])
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(30)
            }
        }
        .navigationTitle("在线客服")
        .onAppear {
            Task {
                compList = await CSComp.list
            }
        }
    }
}

#Preview {
    Box.isPreview = true
    return CustomServiceView()
}

private struct CompView: View {
    @Binding var comp: CSComp
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image.cs.comp
                Text(comp.name)
                    .customText(size: 18, color: .text.gray3, weight: .medium)
                Spacer()
                Image.main.arrowIconDown
                    .rotationEffect(comp.expanded ? .zero : Angle(degrees: -90))
            }
            .frame(height: 40)
            .background(Color.white)
            .onTapGesture {
                withAnimation {
                    comp.expanded.toggle()
                }
            }
            Divider()
            if comp.expanded {
                ForEach(Array(zip(comp.depts.indices, comp.depts)), id: \.0) { idx, dept in
                    DeptView(dept: $comp.depts[idx])
                }
            }
        }
    }
}

private struct DeptView: View {
    @Binding var dept: CSDept
    
    @State private var showChild = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image.cs.dept
                Text(dept.name)
                    .customText(size: 18, color: .text.gray3)
                Spacer()
                Image.main.arrowIconDown
                    .rotationEffect(dept.expanded ? .zero : Angle(degrees: -90))
            }
            .frame(height: 40)
            .padding(.leading, 17)
            .background(Color.white)
            .onTapGesture {
                withAnimation {
                    dept.expanded.toggle()
                }
            }
            if showChild {
                ForEach(Array(zip(dept.users.indices, dept.users)), id: \.0) { idx, user in
                    UserView(user: user, hideUpBar: idx == 0, hideDownBar: idx == dept.users.count - 1)
                }
            }
        }
        .onChange(of: dept.expanded) { expanded in
            if expanded {
                Task {
                    await dept.load()
                    
                    withAnimation {
                        showChild = true
                    }
                }
            } else {
                withAnimation {
                    showChild = false
                }
            }
        }
    }
}

private struct UserView: View {
    let user: CSUser
    let hideUpBar: Bool
    let hideDownBar: Bool
    
    var body: some View {
        HStack {
            VStack {
                if hideUpBar {
                    Spacer().frame(height: 20)
                } else {
                    Color.main
                        .frame(width: 1, height: 20)
                }
                Spacer().frame(height: 2)
                Color.main
                    .frame(width: 10, height: 10)
                    .cornerRadius(5)
                Spacer().frame(height: 2)
                if hideDownBar {
                    Spacer().frame(height: 20)
                } else {
                    Color.main
                        .frame(width: 1, height: 20)
                }
            }
            .frame(width: 24)
            HStack {
                Image.cs.person
                Text(user.name)
                    .customText(size: 16, color: .text.gray6)
                Spacer()
            }
            .padding(.horizontal, 15)
            .frame(width: 266, height: 44)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: .black.opacity(0.08), radius: 3)
            Spacer()
        }
        .padding(.leading, 17)
    }
}
