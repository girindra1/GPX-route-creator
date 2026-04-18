//
//  SettingsView.swift
//  GPX route creator
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("preferLoopRoutes") private var preferLoopRoutes = true
    @AppStorage("showImportedGPXOnPlan") private var showImportedGPXOnPlan = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Planning Defaults") {
                    Toggle("Prefer loop routes", isOn: $preferLoopRoutes)
                    Toggle("Show imported GPX in Plan", isOn: $showImportedGPXOnPlan)
                }

                Section("Data") {
                    LabeledContent("Bundled route source", value: "Routes folder")
                    LabeledContent("Current mode", value: "Local GPX testing")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
