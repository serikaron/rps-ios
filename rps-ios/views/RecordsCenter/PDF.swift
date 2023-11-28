//
//  PDF.swift
//  rps-ios
//
//  Created by serika on 2023/11/28.
//

import SwiftUI
import PDFKit

struct PDF: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        
    }
    
    typealias UIViewType = PDFView
}

struct ComplexPDF: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var estateService: EstateService
    let id: Int
    
    @State private var urlString: String = ""
    
    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                PDF(url: url)
            } else {
                Color.white
            }
        }
        .setupNavigationBar(title: "报告预览", {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            Task {
                urlString = await estateService.complexReportPdf(id: id)
            }
        }
    }
}

struct ConsultPDF: View {
    @EnvironmentObject var estateService: EstateService
    let inquiryId: Int
    
    @State private var urlString: String = ""
    
    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                PDF(url: url)
            } else {
                Color.white
            }
        }
        .onAppear {
            Task {
                urlString = await estateService.consultReportPdf(inquiryId: inquiryId)
            }
        }
    }
}

//#Preview {
//    PDF(url:
//}
