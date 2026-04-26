//
//  TrainStationLibrary.swift
//  GPX route creator
//

import CoreLocation
import Foundation

struct TrainStation: Identifiable, Hashable {
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    var id: String { name }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct TrainStationLibrary {
    let settleCarlisleStations: [TrainStation] = [
        TrainStation(name: "Settle", latitude: 54.0669551, longitude: -2.2808342),
        TrainStation(name: "Giggleswick", latitude: 54.0617706, longitude: -2.3028455),
        TrainStation(name: "Horton-in-Ribblesdale", latitude: 54.1492195, longitude: -2.3020792),
        TrainStation(name: "Ribblehead", latitude: 54.2056018, longitude: -2.3607019),
        TrainStation(name: "Dent", latitude: 54.2825669, longitude: -2.3635911),
        TrainStation(name: "Garsdale", latitude: 54.3214617, longitude: -2.3263682),
        TrainStation(name: "Kirkby Stephen", latitude: 54.4549076, longitude: -2.3687030)
    ]

    func stations(matching query: String) -> [String] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if normalizedQuery.isEmpty {
            return settleCarlisleStations.map(\.name)
        }

        return settleCarlisleStations.filter { station in
            station.name.localizedCaseInsensitiveContains(normalizedQuery)
        }
        .map(\.name)
    }

    func station(named name: String) -> TrainStation? {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        return settleCarlisleStations.first { station in
            station.name.caseInsensitiveCompare(normalizedName) == .orderedSame
        }
    }
}
