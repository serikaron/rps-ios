//
//  MapView.swift
//  rps-ios
//
//  Created by serika on 2023/11/24.
//

import SwiftUI
import MAMapKit

struct MapView: UIViewRepresentable {
    
    var mapViewCoordinate: MapViewCoordinate?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias UIViewType = MAMapView
    
    func makeUIView(context: Context) -> MAMapView {
        let out = MAMapView()
        out.delegate = context.coordinator
        out.userTrackingMode = .follow
        out.showsUserLocation = true
        update(view: out)
        return out
    }
    
    func updateUIView(_ uiView: MAMapView, context: Context) {
        update(view: uiView)
    }
    
    private func update(view: MAMapView) {
        guard let mapViewCoordinate = mapViewCoordinate else { return }
        print("mapView center: \(MAMapPointForCoordinate(mapViewCoordinate.center))")
        
        view.setCenter(mapViewCoordinate.center, animated: true)
        if let overlay = mapViewCoordinate.overlay {
            view.add(overlay)
            print("mapView boundary: \(overlay.boundingMapRect())")
            view.setVisibleMapRect(
                overlay.boundingMapRect(),
                edgePadding: .init(top: 10, left: 10, bottom: 10, right: 10),
                animated: true)
        } else if let pointAnnotation = mapViewCoordinate.pointAnnotation {
            view.addAnnotation(pointAnnotation)
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
        
        func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
            if let _ = overlay as? MAPolyline {
                let out = MAPolylineRenderer(overlay: overlay)
                out?.lineWidth = 2.0
                out?.strokeColor = Color.hex("#3d7fff").uiColor
                out?.lineJoinType = kMALineJoinRound
                out?.lineCapType = kMALineCapRound
                return out
            }
            if let _ = overlay as? MAPolygon {
                let out = MAPolygonRenderer(overlay: overlay)
                out?.lineWidth = 2.0
                out?.strokeColor = Color.hex("#3d7fff").uiColor
                out?.fillColor = Color.hex("#c6e2ff").uiColor.withAlphaComponent(0.2)
                out?.lineJoinType = kMALineJoinRound
                out?.lineCapType = kMALineCapRound
                return out
            }
            return nil
        }
    }
}

#Preview {
    MapService.initMAMapKit()
    return MapView(mapViewCoordinate: .mock)
}

private extension MapViewCoordinate {
    var center: Coordinate {
        switch self {
        case .point(let l):
            return l[0]
        case .line(let l):
            return l.avg
        case .plane(let l):
            return l.avg
        }
    }
    
    var overlay: MAOverlay? {
        switch self {
        case .point: return nil
        case .line(let l):
            return MAPolyline(coordinates: l.unsafePointer, count: UInt(l.count))
        case .plane(let l):
            return MAPolygon(coordinates: l.unsafePointer, count: UInt(l.count))
        }
    }
    
    var pointAnnotation: MAPointAnnotation? {
        switch self {
        case .point(let l):
            let out = MAPointAnnotation()
            out.coordinate = l[0]
            return out
        default: return nil
        }
    }
}

private extension [Coordinate] {
    var avg: Coordinate {
//        return Coordinate(latitude: 60, longitude: 60)
        return self.reduce(Coordinate(latitude: 0, longitude: 0)) { partialResult, curr in
            partialResult + curr / Double(self.count)
        }
    }
    
    var unsafePointer: UnsafeMutablePointer<CLLocationCoordinate2D> {
        let out = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
        out.initialize(from: self, count: count)
        return out
    }
}

private extension Coordinate {
    static func + (lhs: Self, rhs: Self) -> Self {
        return Coordinate(latitude: lhs.latitude+rhs.latitude, longitude: lhs.longitude+rhs.longitude)
    }
    static func - (lhs: Self, rhs: Self) -> Self {
        return Coordinate(latitude: lhs.latitude-rhs.latitude, longitude: lhs.longitude-rhs.longitude)
    }
    static func / (c: Self, divider: Double) -> Self {
        return Coordinate(latitude: c.latitude / divider, longitude: c.longitude / divider)
    }
    static func * (c: Self, multipier: Double) -> Self {
        return Coordinate(latitude: c.latitude * multipier, longitude: c.longitude * multipier)
    }
}
