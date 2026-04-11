//
//  GPXTrack.swift
//  GPX route creator
//

import CoreLocation
import Foundation

struct GPXTrackPoint: Identifiable, Codable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let elevationMeters: Double?
    let timestamp: Date?

    init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        elevationMeters: Double? = nil,
        timestamp: Date? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.elevationMeters = elevationMeters
        self.timestamp = timestamp
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct GPXTrackSegment: Codable {
    let points: [GPXTrackPoint]
}

struct GPXTrack: Codable {
    let name: String?
    let segments: [GPXTrackSegment]

    var pointCount: Int {
        segments.reduce(into: 0) { partialResult, segment in
            partialResult += segment.points.count
        }
    }
}
