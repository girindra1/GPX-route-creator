//
//  ParsedGPXFile.swift
//  GPX route creator
//

import CoreLocation
import Foundation

struct ParsedGPXFile: Identifiable {
    let id = UUID()
    let fileName: String
    let displayName: String
    let segmentCount: Int
    let pointCount: Int
    let distanceKilometers: Double
    let elevationGainMeters: Int
    let coordinates: [CLLocationCoordinate2D]
}
