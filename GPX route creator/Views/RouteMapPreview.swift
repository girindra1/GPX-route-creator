//
//  RouteMapPreview.swift
//  GPX route creator
//

import MapKit
import SwiftUI

struct RouteMapPreview: View {
    let coordinates: [CLLocationCoordinate2D]

    var body: some View {
        Map(initialPosition: initialPosition, interactionModes: []) {
            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates)
                    .stroke(.blue, lineWidth: 4)
            }

            if let start = coordinates.first {
                Marker("Start", coordinate: start)
                    .tint(.green)
            }

            if let end = coordinates.last, coordinates.count > 1 {
                Marker("Finish", coordinate: end)
                    .tint(.red)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .id(mapIdentity)
    }

    private var initialPosition: MapCameraPosition {
        if coordinates.count > 1 {
            return .rect(mapRect)
        }

        if let coordinate = coordinates.first {
            return .region(
                MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 2_500,
                    longitudinalMeters: 2_500
                )
            )
        }

        return .automatic
    }

    private var mapRect: MKMapRect {
        let points = coordinates.map(MKMapPoint.init)

        guard let firstPoint = points.first else {
            return .world
        }

        let baseRect = MKMapRect(origin: firstPoint, size: MKMapSize(width: 0, height: 0))
        let rawRect = points.dropFirst().reduce(baseRect) { partialRect, point in
            partialRect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
        }

        let horizontalPadding = max(rawRect.size.width * 0.2, 2_500)
        let verticalPadding = max(rawRect.size.height * 0.2, 2_500)
        return rawRect.insetBy(dx: -horizontalPadding, dy: -verticalPadding)
    }

    private var mapIdentity: String {
        coordinates
            .map { "\($0.latitude),\($0.longitude)" }
            .joined(separator: "|")
    }
}
