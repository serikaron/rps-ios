//
//  NoticeListView.swift
//  rps-ios
//
//  Created by serika on 2024/1/3.
//

import SwiftUI

struct NoticeListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject private var accountService: AccountService
    @State private var noticeList = [Notice]()
    @State private var currPage = 1
    @State private var total = Int.max
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(zip(noticeList.indices, noticeList)), id: \.0) { idx, notice in
                    VStack(spacing: 0) {
                        view(for: notice)
                            .onAppear {
                                if idx == noticeList.count - 2 {
                                    load()
                                }
                            }
                        if idx != noticeList.count - 1 {
                            Color.text.grayCD
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
        .onAppear {
            load()
        }
        .setupNavigationBar(title: "公告列表", {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    private func load() {
        guard let orgId = accountService.account?.orgId,
              orgId != 0
        else { return }
        
        
        guard noticeList.count < total else { return }
        
        Task {
            let (l, total, curr) = await Notice.list(
                pageNum: currPage,
                pageSize: 10,
                orgId: orgId)
            self.total = total
            
            guard currPage == curr else { return }
            
            currPage += 1
            noticeList.append(contentsOf: l)
            print("Notice \(noticeList)")
        }
    }
    
    private func view(for notice: Notice) -> some View {
        NavigationLink(destination: NoticeDetailView(notice: notice)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(notice.title)
                        .customText(size: 16, color: .text.gray3, weight: .medium)
                    Text(notice.date)
                        .customText(size: 14, color: .text.gray6)
                }
                Spacer()
                Image.main.arrowIconRight
            }
            .frame(height: 66)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    NavigationView {
        NoticeListView()
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(AccountService.preview)
    }
}
