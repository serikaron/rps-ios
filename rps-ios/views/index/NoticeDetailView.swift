//
//  NoticeDetailView.swift
//  rps-ios
//
//  Created by serika on 2024/1/3.
//

import SwiftUI
import WebKit

struct NoticeDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let notice: Notice
    
    var body: some View {
        WebView(content: notice.content)
            .setupNavigationBar(title: notice.title, {
                presentationMode.wrappedValue.dismiss()
            })
            .padding()
    }
}

private struct WebView: UIViewRepresentable {
    let content: String
    
    typealias UIViewType = WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(content, baseURL: nil)
    }
}

#Preview {
    NavigationView {
        NoticeDetailView(notice: Notice.mock[0])
            .navigationBarTitleDisplayMode(.inline)
    }
}

