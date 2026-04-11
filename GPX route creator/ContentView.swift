//
//  ContentView.swift
//  GPX route creator
//
//  Created by Girindra Ramgobin on 04/04/2026.
//

import SwiftUI

struct ContentView: View {
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
                    plannerSection
                    resultsSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("GPX Route Creator")
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan a mountain bike ride from a train station")
                .font(.title.bold())

            Text("Enter the station you want to start from and choose whether you want a loop or one-way track. The app will suggest matching GPX-ready rides.")
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

#Preview {
    ContentView()
}
