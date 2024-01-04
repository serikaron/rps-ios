//
//  OCRButton.swift
//  rps-ios
//
//  Created by serika on 2023/12/11.
//

import SwiftUI

struct OCRButton<Content: View>: View {
    @EnvironmentObject var estateService: EstateService
    
    @State private var showImpagePicker = false
    @State private var ocrImage = ImagePicker.ImageInfo(image: UIImage(), imageURL: "")
    @State private var navOcr = false
    @State private var ocrResult: SearchResult?
    @State private var ocrArea = ""
    
    let content: () -> Content
    
    var body: some View {
//        Image.index.searchOCR
        content()
            .onTapGesture {
                showImpagePicker = true
            }
            .sheet(isPresented: $showImpagePicker, content: {
                ImagePicker(selectedImage: $ocrImage)
            })
            .onChange(of: ocrImage) { _ in
                guard !ocrImage.imageURL.isEmpty else { return }
                Task {
                    let (searchResult, area) = await estateService.ocr(image: .from(pickerImage: ocrImage))
                    guard let searchResult = searchResult,
                          let area = area
                    else {
                        Box.sendError("识别失败")
                        return
                    }
                    ocrResult = searchResult
                    ocrArea = area
                    navOcr = true
                }
            }
            .overlay (
                NavigationLink(
                    destination: RoomDetailView(
                        familyRoomName: ocrResult?.roomName ?? "",
                        areaCode: ocrResult?.areacode ?? 0,
                        estateType: ocrResult?.estateType ?? "",
                        buildingId: ocrResult?.buildingId ?? 0,
                        area: ocrArea,
                        dataOrgId: ocrResult?.orgId ?? 0,
                        floor: ocrResult?.floor ?? ""),
                    isActive: $navOcr) {
                        EmptyView()
                    }
            )
    }
}

#Preview {
    OCRButton() {
        Image.index.searchOCR
    }
}
