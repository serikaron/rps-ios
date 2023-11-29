//
//  PDF.swift
//  rps-ios
//
//  Created by serika on 2023/11/28.
//

import SwiftUI
import PDFKit

private struct PDFRprs: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
    
    typealias UIViewType = PDFView
}

private struct PDFWrapper: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var urlString: String
    @State private var document: PDFDocument?
    
    var body: some View {
        Group {
            if let document = document {
                ScrollView {
                    PDFRprs(document: document)
                }
            } else {
                Color.white
            }
        }
        .onChange(of: urlString) { _ in loadDocument() }
        .setupNavigationBar(title: "报告预览", {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    private func loadDocument() {
        DispatchQueue.global(qos: .background).async {
//            print("pdf url: \(urlString)")
            if let url = URL(string: urlString) {
                document = PDFDocument(url: url)
            } else {
                document = nil
            }
        }
    }
}

struct ComplexPDF: View {
    @EnvironmentObject var estateService: EstateService
    let id: Int
    
    @State private var urlString: String = ""
    
    var body: some View {
        PDFWrapper(urlString: $urlString)
        .onAppear {
            Task {
                let u = await estateService.complexReportPdf(id: id)
                if u.isEmpty {
                    Box.sendError("找不到报告")
                } else {
                    urlString = u
                }
            }
        }
    }
}

struct ConsultPDF: View {
    @EnvironmentObject var estateService: EstateService
    let inquiryId: Int
    
    @State private var urlString: String = ""
    
    var body: some View {
        PDFWrapper(urlString: $urlString)
        .onAppear {
//            urlString = "https://image.xuboren.com/image/2023/11/29/ce4e0a3a2cbf4c408b5721fc1d6bec0f.pdf"
            Task {
                let u = await estateService.consultReportPdf(inquiryId: inquiryId)
                if u.isEmpty {
                    Box.sendError("找不到报告")
                } else {
                    urlString = u
                }
            }
        }
    }
}

//#Preview {
//    PDF(url: URL(string: "https://image.xuboren.com/image/2023/11/29/ce4e0a3a2cbf4c408b5721fc1d6bec0f.pdf")!)
//    ConsultPDF(inquiryId: 0)
//        .environmentObject(EstateService.preview)
//}
