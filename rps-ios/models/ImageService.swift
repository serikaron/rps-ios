//
//  ImageService.swift
//  rps-ios
//
//  Created by serika on 2024/1/3.
//

import Foundation
import SwiftUI

@MainActor
class ImageService: ObservableObject {
    @Published var imageDict = [URL: Data]()
    private var loadingFlags = [URL: Bool]()
    
    func loadImage(url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            imageDict[url] = data
            loadingFlags[url] = false
//            print("imageService.loadImage done: \(url.absoluteString)")
        } catch {
            print("loadImage FILED!!! url:\(url.absoluteString) error:\(error)")
        }
    }
    
    func image(of url: URL) -> Image {
//        print("image of: \(url)")
        if let data = imageDict[url],
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
            
        if !(loadingFlags[url] ?? false) {
            loadingFlags[url] = true
            Task {
                await loadImage(url: url)
            }
        }
            
        return Image.main.placeholder
    }
}
