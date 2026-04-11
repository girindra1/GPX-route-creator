//
//  RouteLibrary.swift
//  GPX route creator
//

import Foundation

struct RouteLibrary {
    private let allRoutes: [GPXRoute] = [
        GPXRoute(
            name: "Nordkette Forest Circuit",
            station: "Innsbruck",
            trackType: .loop,
            distanceKilometers: 28.4,
            elevationGainMeters: 950,
            summary: "A technical alpine loop with forest descents and fast valley connectors.",
            gpxFileName: "nordkette-forest-circuit.gpx"
        ),
        GPXRoute(
            name: "Mutters Ridge Traverse",
            station: "Innsbruck",
            trackType: .oneWay,
            distanceKilometers: 31.2,
            elevationGainMeters: 780,
            summary: "A point-to-point ride with a big ridgeline section and an easy train return.",
            gpxFileName: "mutters-ridge-traverse.gpx"
        ),
        GPXRoute(
            name: "Chamonix Valley Singletrack",
            station: "Chamonix",
            trackType: .oneWay,
            distanceKilometers: 24.8,
            elevationGainMeters: 620,
            summary: "Scenic valley flow trails connected by lift-accessed descents and a station pickup.",
            gpxFileName: "chamonix-valley-singletrack.gpx"
        ),
        GPXRoute(
            name: "Finale Backcountry Loop",
            station: "Finale Ligure",
            trackType: .loop,
            distanceKilometers: 36.5,
            elevationGainMeters: 1120,
            summary: "A demanding Mediterranean loop with rocky climbs, ridge views, and classic enduro descents.",
            gpxFileName: "finale-backcountry-loop.gpx"
        ),
        GPXRoute(
            name: "Peaks to Platform",
            station: "Aosta",
            trackType: .oneWay,
            distanceKilometers: 18.6,
            elevationGainMeters: 410,
            summary: "A shorter descending route designed to finish directly at the train platform.",
            gpxFileName: nil
        )
    ]

    func routes(near stationQuery: String, trackType: TrackType) -> [GPXRoute] {
        let normalizedQuery = stationQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        return allRoutes
            .filter { route in
                route.trackType == trackType &&
                (normalizedQuery.isEmpty || route.station.localizedCaseInsensitiveContains(normalizedQuery))
            }
            .sorted { first, second in
                first.distanceKilometers < second.distanceKilometers
            }
    }
}
