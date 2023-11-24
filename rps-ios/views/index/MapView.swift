//
//  MapView.swift
//  rps-ios
//
//  Created by serika on 2023/11/24.
//

import SwiftUI
import MAMapKit

struct MapView: UIViewRepresentable {
    
    @Binding var coordinate: Coordinate?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias UIViewType = MAMapView
    
    func makeUIView(context: Context) -> MAMapView {
        let out = MAMapView()
        out.delegate = context.coordinator
        out.userTrackingMode = .follow
        out.showsUserLocation = true
//        update(view: out)
        return out
    }
    
    func updateUIView(_ uiView: MAMapView, context: Context) {
        update(view: uiView)
    }
    
    private func update(view: MAMapView) {
        print("update 1")
        if let coordinate = coordinate {
            print("update 2")
            view.centerCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    final class Coordinator: NSObject, MAMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

#Preview {
    MapService.initMAMapKit()
    return MapView(coordinate: .constant(nil))
}
