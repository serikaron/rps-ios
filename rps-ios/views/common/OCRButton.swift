//
//  OCRButton.swift
//  rps-ios
//
//  Created by serika on 2023/12/11.
//

import SwiftUI

struct OCRButton<Content: View>: View {
    @EnvironmentObject private var estateService: EstateService
    @EnvironmentObject private var areaTreeService: AreaTreeService
    @EnvironmentObject private var accountService: AccountService
    
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
                    Box.setLoading(true)
                    if areaTreeService.userAreaTree == nil,
                       let unitId = accountService.account?.unitId
                    {
                        await areaTreeService.loadUserAreaTree(with: unitId)
                    }
                    
                    guard let provinceCode = areaTreeService.userAreaTree?.provinceCode,
                          let cityCode = areaTreeService.userAreaTree?.cityCode
                    else {
                        Box.sendError("用户资料出错")
                        Box.setLoading(false)
                        return
                    }

                    let (searchResult, area) = await estateService.ocr(
                        image: .from(pickerImage: ocrImage),
                        provinceCode: provinceCode,
                        cityCode: cityCode
                    )
                    Box.setLoading(false)
                    
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
            .onAppear {
                Task {

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
