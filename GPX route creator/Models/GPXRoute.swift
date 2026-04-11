//
//  GPXRoute.swift
//  GPX route creator
//

import Foundation

struct GPXRoute: Identifiable, Codable {
    let id: UUID
    let name: String
    let station: String
    let trackType: TrackType
    let distanceKilometers: Double
    let elevationGainMeters: Int
    let summary: String
    let gpxFileName: String?

    init(
        id: UUID = UUID(),
        name: String,
        station: String,
        trackType: TrackType,
        distanceKilometers: Double,
        elevationGainMeters: Int,
        summary: String,
        gpxFileName: String?
    ) {
        self.id = id
        self.name = name
        self.station = station
        self.trackType = trackType
        self.distanceKilometers = distanceKilometers
        self.elevationGainMeters = elevationGainMeters
        self.summary = summary
        self.gpxFileName = gpxFileName
    }
}
