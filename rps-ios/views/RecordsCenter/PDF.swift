//
//  PDF.swift
//  rps-ios
//
//  Created by serika on 2023/11/28.
//

import SwiftUI
import PDFKit

private struct PDFRprs: UIViewRepresentable {
    let document: PDFDocument?
    
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

    @State private var document: PDFDocument?
    
    let action: () async -> String
    
    var body: some View {
        PDFRprs(document: document)
        .setupNavigationBar(title: "报告预览", {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            Task {
                let u = await action()
                print("pdf: \(u)")
                if let url = URL(string: u) {
                    document = PDFDocument(url: url)
                } else {
                    Box.sendError("找不到报告")
                }
            }
        }
    }
}

struct ComplexPDF: View {
    @EnvironmentObject var estateService: EstateService
    let id: Int
    
    var body: some View {
        PDFWrapper {
            await estateService.complexReportPdf(id: id)
        }
    }
}

struct ConsultPDF: View {
    @EnvironmentObject var estateService: EstateService
    let inquiryId: Int
    
    @State private var urlString: String = ""
    
    var body: some View {
        PDFWrapper {
            await estateService.consultReportPdf(inquiryId: inquiryId)
        }
    }
}

//#Preview {
//    PDF(url: URL(string: "https://image.xuboren.com/image/2023/11/29/ce4e0a3a2cbf4c408b5721fc1d6bec0f.pdf")!)
//    ConsultPDF(inquiryId: 0)
//        .environmentObject(EstateService.preview)
//}
