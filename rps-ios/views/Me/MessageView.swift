//
//  MessageView.swift
//  rps-ios
//
//  Created by serika on 2023/11/23.
//

import SwiftUI

struct MessageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var accountService: AccountService
    
    @State private var messages = [Message]()
    @State private var unread = 0
    
    let pageSize = 10
    @State private var pageNum = 0
    @State private var total = Int.max
    
    var body: some View {
        ScrollView {
            VStack(spacing:10) {
                HStack {
                    Text("通知短信")
                        .customText(size: 16, color: .main)
                    Text("\(max(unread, 0))")
                        .customText(size: 10, color: .white)
                        .frame(width: 16, height: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .frame(height: 44)
                LazyVStack(spacing: 10, content: {
                    ForEach(Array(zip(messages.indices, messages)), id: \.0) { idx, msg in
                        NavigationLink {
                            MessageDetailView(message: $messages[idx], unread: $unread)
                                .onAppear {
                                    unread += 1
                                }
                        } label: {
                            HStack {
                                Group {
                                    if msg.read {
                                        Color.clear
                                    } else {
                                        Color.red
                                    }
                                }
                                .frame(width: 6, height: 6)
                                .clipShape(Circle())
                                Text(msg.content)
                                    .lineLimit(1)
                                    .customText(size: 14, color: .text.gray6, weight: .medium)
                                Spacer()
                                Text(msg.date)
                                    .customText(size: 12, color: .text.gray6)
                            }
                            .frame(height: 44)
                            .padding(.horizontal, 12)
                            .background(Color.hex("#F4F4F4"))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .onAppear {
                                if idx == messages.count - 2{
                                    load()
                                }
                            }
                        }
                    }
                })
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            load()
            Task {
                unread = await accountService.getUnread()
            }
        }
        .setupNavigationBar(title: "收件箱") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func load() {
        guard messages.count < total else { return }
        
        Task {
            let rsp = await accountService.getMessage(pageNum: pageNum + 1, pageSize: pageSize)
            guard pageNum == rsp.current - 1 else { return }
            total = rsp.total
            pageNum = rsp.current
            messages.append(contentsOf: rsp.list)
        }
    }
}

#Preview {
    NavigationView {
        MessageView()
            .environmentObject(AccountService.preview)
    }
}

private struct MessageDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var accountService: AccountService

    @Binding var message: Message
    @Binding var unread: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("发件人:  \(message.sender)")
                    .customText(size: 16, color: .text.gray3, weight: .medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(message.date)
                    .customText(size: 14, color: .text.gray6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                Text(message.content)
                    .customText(size: 14, color: .text.gray6, weight: .medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .setupNavigationBar(title: "收件箱") {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            if !message.read {
                Task {
                    await accountService.readMessage(id: message.id)
                    message.read = true
                    unread -= 1
                }
            }
        }
    }
}

//#Preview("detail") {
//    MessageDetailView(message: .constant(.mock[0]), unread: .constant(0))
//}

