//
//  GPXLoader.swift
//  GPX route creator
//

import CoreLocation
import Foundation

enum GPXLoaderError: LocalizedError {
    case noGPXFilesFound

    var errorDescription: String? {
        switch self {
        case .noGPXFilesFound:
            return "No bundled GPX files were found."
        }
    }
}

struct GPXLoader {
    private let parser = GPXParser()

    func loadBundledFiles() throws -> [ParsedGPXFile] {
        let urls = bundledGPXURLs()

        guard !urls.isEmpty else {
            throw GPXLoaderError.noGPXFilesFound
        }

        return try urls.map(loadFile(from:)).sorted { $0.displayName < $1.displayName }
    }

    private func bundledGPXURLs() -> [URL] {
        let directoryURLs = Bundle.main.urls(forResourcesWithExtension: "gpx", subdirectory: "Routes") ?? []
        let rootURLs = Bundle.main.urls(forResourcesWithExtension: "gpx", subdirectory: nil) ?? []

        return Array(Set(directoryURLs + rootURLs)).sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func loadFile(from url: URL) throws -> ParsedGPXFile {
        let track = try parser.parse(contentsOf: url)
        let allPoints = track.segments.flatMap(\.points)

        return ParsedGPXFile(
            fileName: url.lastPathComponent,
            displayName: track.name ?? url.deletingPathExtension().lastPathComponent,
            segmentCount: track.segments.count,
            pointCount: allPoints.count,
            distanceKilometers: totalDistance(for: track),
            elevationGainMeters: totalElevationGain(for: track),
            coordinates: allPoints.map(\.coordinate)
        )
    }

    private func totalDistance(for track: GPXTrack) -> Double {
        let distanceMeters = track.segments.reduce(0.0) { total, segment in
            total + zip(segment.points, segment.points.dropFirst()).reduce(0.0) { subtotal, pair in
                let first = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
                let second = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
                return subtotal + first.distance(from: second)
            }
        }

        return distanceMeters / 1_000
    }

    private func totalElevationGain(for track: GPXTrack) -> Int {
        let gain = track.segments.reduce(0.0) { total, segment in
            total + zip(segment.points, segment.points.dropFirst()).reduce(0.0) { subtotal, pair in
                guard
                    let previousElevation = pair.0.elevationMeters,
                    let currentElevation = pair.1.elevationMeters
                else {
                    return subtotal
                }

                return subtotal + max(currentElevation - previousElevation, 0)
            }
        }

        return Int(gain.rounded())
    }
}
