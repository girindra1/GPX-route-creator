//
//  PlanView.swift
//  GPX route creator
//

import SwiftUI

struct PlanView: View {
    let parsedFiles: [ParsedGPXFile]
    let parsedFilesError: String?
    let reloadAction: () -> Void

    @State private var stationName = ""
    @State private var selectedTrackType: TrackType = .loop

    private let routeLibrary = RouteLibrary()

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
            } else if parsedFiles.isEmpty {
                ProgressView("Loading GPX files...")
                    .frame(maxWidth: .infinity, alignment: .leading)
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
            Text("Route Inputs")
                .font(.headline)

            TextField("Train station", text: $stationName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Picker("Track type", selection: $selectedTrackType) {
                ForEach(TrackType.allCases) { trackType in
                    Text(trackType.title).tag(trackType)
                }
            }
            .pickerStyle(.segmented)

            Text(selectedTrackType.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
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
                    description: Text("Try a station like Innsbruck, Chamonix, or Finale Ligure, or add your own GPX routes to the library.")
                )
            } else {
                ForEach(suggestedRoutes) { route in
                    RouteCard(route: route)
                }
            }
        }
    }
}
