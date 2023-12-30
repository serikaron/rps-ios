//
//  PDFShareSheet.swift
//  rps-ios
//
//  Created by serika on 2023/12/30.
//

import SwiftUI

struct PDFShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

private struct WrapView: View {
    
    @State private var data: Data?
    
    var body: some View {
        Button("show") {
            Task {
                if let d = await download() {
                    data = d
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { self.data != nil },
            set: { show in
                if !show {
                    data = nil
                }
            }), content: {
            PDFShareSheet(activityItems: [data!])
        })
    }
    
    private func download() async -> Data? {
        do {
            let url = URL(string: "https://image.xuboren.com/image/2023/12/28/6c05b422f08a4d34b365ed28c9f22252.pdf")!
            let (data, res) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print(error)
            print("downloadAndSave FAILED!!!")
            return nil
        }
    }

}

#Preview {
    WrapView()
}
