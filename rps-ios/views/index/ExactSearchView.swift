//
//  ExactSearchView.swift
//  rps-ios
//
//  Created by serika on 2023/11/10.
//

import SwiftUI
import SBPAsyncImage

struct ExactSearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    @State var text: String = ""
    
    var resultList: SearchResultList {
        estateService.exactSearchResult
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10)
            SearchInputView(text: $text, searchAction: {
                guard !text.isEmpty else { return }
                search()
            })
            Spacer().frame(height: 10)
            listView
        }
        .padding(.horizontal, 12)
        .background(Color.view.background)
        .setupNavigationBar(title: "小区列表") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func search() {
        Task {
            await estateService.exactSearch(keyword: text)
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        if resultList.isEmpty {
            Image.main.emptyList
        } else {
            List {
                ForEach(Array(zip(resultList.indices, resultList)), id: \.0) { idx, result in
                    ZStack {
                        NavigationLink(
                            destination: BuildingsView(comId: result.comId ?? 0, estateType: result.estateType ?? "")
                                .environmentObject(estateService)
                        ) {
                            EmptyView()
                        }
                        listItem(of: result)
                            .onAppear {
                                if idx == resultList.count - 2 {
                                    search()
                                }
                            }
                    }
                    .listRowBackground(
                        Color.white
                            .cornerRadius(8)
                    )
                }
            }
            .listStyle(.plain)
        }
    }
    
    private func listItem(of result: SearchResult) -> some View {
        VStack {
            HStack {
                Color.main
                    .frame(width: 4, height: 16)
                Spacer().frame(width: 8)
                Text("\(result.completionDate ?? "")建成")
                    .customText(size: 13, color: .text.gray3)
                Spacer().frame(width: 16)
                Text(result.estateTypeLabel ?? "")
                    .customText(size: 12, color: .main)
                Spacer()
                Button {
                    
                } label: {
                    HStack(spacing: 0) {
                        Text("查看楼幢")
                            .customText(size: 13, color: .hex("#4174F8"))
                        Image.main.arrowIcon
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .rotationEffect(Angle(degrees: 180))
                            .foregroundColor(.main)
                    }
                }
            }
            .frame(height: 40)
            HStack(spacing: 10) {
                BackportAsyncImage(url: URL(string: result.picUrls ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Image.main.placeholder.resizable()
                }
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                VStack(alignment: .leading) {
                    Text(result.compoundName ?? "")
                        .customText(size: 16, color: .text.gray3, weight: .bold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(height: 3)
                    Text("小区别名：\(result.compoundNameAlias ?? "")")
                        .customText(size: 12, color: .text.gray3)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(height: 6)
                    Text("地址：\(result.address ?? "")")
                        .customText(size: 12, color: .text.gray3)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 196)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.white)
    }
}

#Preview {
    //            Box.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJycHNfdXNlcjo0MCIsInJuU3RyIjoiQlFpb0p2WUJkaTBzNlRvQ1NtMlg1RmIxRHZuV3NOZUMiLCJ1c2VySWQiOjQwfQ.38Hkz9cSo2tuMGHGilzrlMr3VRgrbUOrLjldbiKUpc8")
    Linkman.shared.standalone = true
    return NavigationView {
        ExactSearchView(text: "abc")
            .environmentObject(EstateService.preview)
    }
}
