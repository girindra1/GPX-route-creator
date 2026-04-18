//
//  ContentView.swift
//  GPX route creator
//
//  Created by Girindra Ramgobin on 04/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .plan
    @State private var parsedFiles: [ParsedGPXFile] = []
    @State private var parsedFilesError: String?

    private let gpxLoader = GPXLoader()

    var body: some View {
        TabView(selection: $selectedTab) {
            PlanView(
                parsedFiles: parsedFiles,
                parsedFilesError: parsedFilesError,
                reloadAction: loadBundledGPXFiles
            )
            .tabItem {
                Label("Plan", systemImage: "map.fill")
            }
            .tag(AppTab.plan)

            RoutesView(
                parsedFiles: parsedFiles,
                parsedFilesError: parsedFilesError,
                reloadAction: loadBundledGPXFiles
            )
            .tabItem {
                Label("Routes", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
            }
            .tag(AppTab.routes)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
        }
        .task {
            if parsedFiles.isEmpty && parsedFilesError == nil {
                loadBundledGPXFiles()
            }
        }
    }

    private func loadBundledGPXFiles() {
        do {
            parsedFiles = try gpxLoader.loadBundledFiles()
            parsedFilesError = nil
        } catch {
            parsedFiles = []
            parsedFilesError = error.localizedDescription
        }
    }
}

private enum AppTab {
    case plan
    case routes
    case settings
}

#Preview {
    ContentView()
}
