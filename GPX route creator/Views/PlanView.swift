//
//  PlanView.swift
//  GPX route creator
//

import CoreLocation
import SwiftUI

struct PlanView: View {
    let parsedFiles: [ParsedGPXFile]
    let isLoadingParsedFiles: Bool
    let parsedFilesError: String?
    let reloadAction: () -> Void

    @State private var stationName = ""
    @State private var destinationStationName = ""
    @State private var selectedTrackType: TrackType = .loop

    private let routeLibrary = RouteLibrary()
    private let trainStationLibrary = TrainStationLibrary()

    private var matchingStations: [String] {
        trainStationLibrary.stations(matching: stationName)
    }

    private var selectedStation: TrainStation? {
        trainStationLibrary.station(named: stationName)
    }

    private var matchingDestinationStations: [String] {
        trainStationLibrary
            .stations(matching: destinationStationName)
            .filter { $0.caseInsensitiveCompare(stationName) != .orderedSame }
    }

    private var selectedDestinationStation: TrainStation? {
        trainStationLibrary.station(named: destinationStationName)
    }

    private var plannerPreviewCoordinates: [CLLocationCoordinate2D] {
        if selectedTrackType == .oneWay {
            return [selectedStation?.coordinate, selectedDestinationStation?.coordinate].compactMap { $0 }
        }

        return [selectedStation?.coordinate].compactMap { $0 }
    }

    private var suggestedRoutes: [GPXRoute] {
        routeLibrary.routes(
            near: stationName,
            trackType: selectedTrackType
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection
                    importedRoutesSection
                    plannerSection
                    resultsSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Plan")
        }
    }

    private var importedRoutesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Bundled GPX Test Files")
                    .font(.headline)

                Spacer()

                Button("Reload", action: reloadAction)
            }

            if let parsedFilesError {
                ContentUnavailableView(
                    "Could not load GPX files",
                    systemImage: "exclamationmark.triangle",
                    description: Text(parsedFilesError)
                )
            } else if isLoadingParsedFiles {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView("Loading GPX files in the background...")

                    Text("You can still choose a station and plan the ride while route summaries load.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if parsedFiles.isEmpty {
                ContentUnavailableView(
                    "No GPX files loaded",
                    systemImage: "doc",
                    description: Text("Reload to try loading the bundled route files again.")
                )
            } else {
                ForEach(parsedFiles) { file in
                    ParsedGPXFileCard(file: file)
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan a mountain bike ride from a train station")
                .font(.title.bold())

            Text("Use Plan as the default workspace for station input, route shape, and quick GPX checks before you move into the route details tab.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var plannerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Plan your ride")
                .font(.headline)

            Picker("Track type", selection: $selectedTrackType) {
                ForEach(TrackType.allCases) { trackType in
                    Text(trackType.title).tag(trackType)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTrackType) { _, newValue in
                if newValue == .loop {
                    destinationStationName = ""
                }
            }

            Text(selectedTrackType.description)
                .font(.footnote)
                .foregroundStyle(.secondary)

            stationSearchSection(
                title: "Start station",
                placeholder: "Start station",
                stationName: $stationName,
                matchingStations: matchingStations,
                selectedStation: selectedStation
            )

            if selectedTrackType == .oneWay {
                stationSearchSection(
                    title: "Finish station",
                    placeholder: "Finish station",
                    stationName: $destinationStationName,
                    matchingStations: matchingDestinationStations,
                    selectedStation: selectedDestinationStation,
                    emptyStateText: stationName.isEmpty
                        ? "Choose a start station first."
                        : "No other stations match that search."
                )
            }

            if !plannerPreviewCoordinates.isEmpty {
                plannerMapSection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Routes")
                .font(.headline)

            if suggestedRoutes.isEmpty {
                ContentUnavailableView(
                    "No matching routes yet",
                    systemImage: "map",
                    description: Text("Search for a Settle-Carlisle station above. Route suggestions for that start point will appear here as the library is expanded.")
                )
            } else {
                ForEach(suggestedRoutes) { route in
                    RouteCard(route: route)
                }
            }
        }
    }

    private var plannerMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedTrackType == .oneWay ? "Station Preview" : "Start Station Preview")
                .font(.subheadline.weight(.semibold))

            RouteMapPreview(coordinates: plannerPreviewCoordinates)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(
                selectedTrackType == .oneWay
                    ? "The planner map shows the selected start and finish stations."
                    : "The planner map shows the selected starting station."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private func stationSearchSection(
        title: String,
        placeholder: String,
        stationName: Binding<String>,
        matchingStations: [String],
        selectedStation: TrainStation?,
        emptyStateText: String = "No stations match that search."
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            TextField(placeholder, text: stationName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text("Settle-Carlisle line stations from Settle to Kirkby Stephen.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let selectedStation {
                Text(
                    "Stored location: \(selectedStation.latitude.formatted(.number.precision(.fractionLength(4)))), \(selectedStation.longitude.formatted(.number.precision(.fractionLength(4))))"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            LazyVStack(alignment: .leading, spacing: 8) {
                if matchingStations.isEmpty {
                    Text(emptyStateText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                } else {
                    ForEach(matchingStations, id: \.self) { station in
                        Button {
                            stationName.wrappedValue = station
                        } label: {
                            HStack {
                                Label(station, systemImage: "tram.fill")
                                    .font(.subheadline)
                                Spacer()
                                if station == stationName.wrappedValue {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.tint)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                Color(.tertiarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
