//
//  RoutesView.swift
//  GPX route creator
//

import SwiftUI

struct RoutesView: View {
    let parsedFiles: [ParsedGPXFile]
    let parsedFilesError: String?
    let reloadAction: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if let parsedFilesError {
                        ContentUnavailableView(
                            "Could not load routes",
                            systemImage: "exclamationmark.triangle",
                            description: Text(parsedFilesError)
                        )
                    } else if parsedFiles.isEmpty {
                        ProgressView("Loading routes...")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(parsedFiles) { file in
                            VStack(alignment: .leading, spacing: 12) {
                                RouteMapPreview(coordinates: file.coordinates)
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                ParsedGPXFileCard(file: file)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Routes")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Route Library")
                    .font(.title2.bold())

                Spacer()

                Button("Reload", action: reloadAction)
            }

            Text("Review each bundled GPX route with a compact map preview and the core ride stats before you start adding station matching.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
