//
//  ContentView.swift
//  GPX route creator
//
//  Created by Girindra Ramgobin on 04/04/2026.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab: AppTab = .plan
    @State private var parsedFiles: [ParsedGPXFile] = []
    @State private var parsedFilesError: String?
    @State private var isLoadingParsedFiles = false
    @State private var loadTask: Task<Void, Never>?

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            PlanView(
                parsedFiles: parsedFiles,
                isLoadingParsedFiles: isLoadingParsedFiles,
                parsedFilesError: parsedFilesError,
                reloadAction: startBundledGPXFilesLoad
            )
            .tabItem {
                Label("Plan", systemImage: "map.fill")
            }
            .tag(AppTab.plan)

            RoutesView(
                parsedFiles: parsedFiles,
                isLoadingParsedFiles: isLoadingParsedFiles,
                parsedFilesError: parsedFilesError,
                reloadAction: startBundledGPXFilesLoad
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
            if !isRunningInPreview && parsedFiles.isEmpty && parsedFilesError == nil && !isLoadingParsedFiles {
                startBundledGPXFilesLoad()
            }
        }
    }

    @MainActor
    private func startBundledGPXFilesLoad() {
        guard !isLoadingParsedFiles else {
            return
        }

        loadTask?.cancel()
        isLoadingParsedFiles = true
        parsedFilesError = nil

        loadTask = Task {
            do {
                let loadedFiles = try await GPXLoader().loadBundledFiles()

                if !Task.isCancelled {
                    parsedFiles = loadedFiles
                    parsedFilesError = nil
                    isLoadingParsedFiles = false
                }
            } catch {
                if !Task.isCancelled {
                    parsedFiles = []
                    parsedFilesError = error.localizedDescription
                    isLoadingParsedFiles = false
                }
            }
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
