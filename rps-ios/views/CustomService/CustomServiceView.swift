//
//  CustomServiceView.swift
//  rps-ios
//
//  Created by serika on 2023/11/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct CustomServiceView: View {
    @State private var compList = [CSComp]()
    
    @State private var selected: CSUser?
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
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
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(Array(zip(compList.indices, compList)), id: \.0) { idx, comp in
                            CompView(comp: $compList[idx], selected: $selected)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(30)
            }
            
            if selected != nil && selected?.link != nil {
                Color.black.opacity(0.6)
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.2)) {
                            selected = nil
                        }
                    }
                qrCodeView
            }
        }
        .navigationTitle("在线客服")
        .onAppear {
            Task {
                compList = await CSComp.list
            }
        }
    }
    
    private func qrCode(from link: String) -> UIImage {
        filter.message = Data(link.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage()
    }
    
    private var qrCodeView: some View {
        Image.cs.qrCodeBg
            .resizable()
            .frame(width: 222, height: 257)
            .overlay(
                VStack(spacing: 0) {
                    Spacer().frame(height: 18)
                    Text(selected?.name ?? "")
                        .customText(size: 18, color: .black)
                    Spacer().frame(height: 13)
                    Color.white
                        .frame(width: 184, height: 184)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.hex("#E1E3E7"))
                        )
                        .overlay(
                            Image(uiImage: qrCode(from: selected?.link ?? ""))
                                .interpolation(.none)
                                .resizable()
                                .frame(width: 160, height: 160)
                        )
                },
                alignment: .top
            )
    }
}

#Preview {
    Box.isPreview = true
    return CustomServiceView()
}

private struct CompView: View {
    @Binding var comp: CSComp
    @Binding var selected: CSUser?
    
    var body: some View {
        Section(header: header) {
            if comp.expanded {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(Array(zip(comp.depts.indices, comp.depts)), id: \.0) { idx, dept in
                        DeptView(dept: $comp.depts[idx], selected: $selected)
                    }
                }
            }
        }
    }
    
    private var header: some View {
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
        }
    }
}

private struct DeptView: View {
    @Binding var dept: CSDept
    @Binding var selected: CSUser?
    
    @State private var showChild = false
    
    var body: some View {
        Section(header: header) {
            if showChild {
                LazyVStack(spacing: 0) {
                    ForEach(Array(zip(dept.users.indices, dept.users)), id: \.0) { idx, user in
                        UserView(user: user, hideUpBar: idx == 0, hideDownBar: idx == dept.users.count - 1, selected: $selected)
                    }
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
    
    private var header: some View {
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
    }
}

private struct UserView: View {
    let user: CSUser
    let hideUpBar: Bool
    let hideDownBar: Bool
    
    @Binding var selected: CSUser?
    
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
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.1)) {
                            selected = user
                        }
                    }
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
