//
//  RouteCard.swift
//  GPX route creator
//

import SwiftUI

struct RouteCard: View {
    let route: GPXRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.headline)

                    Text(route.station)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(route.trackType.badgeTitle)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(route.trackType.badgeColor.opacity(0.18), in: Capsule())
            }

            HStack {
                Label("\(route.distanceKilometers.formatted(.number.precision(.fractionLength(0...1)))) km", systemImage: "figure.outdoor.cycle")
                Spacer()
                Label("\(route.elevationGainMeters) m", systemImage: "mountain.2")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text(route.summary)
                .font(.callout)

            if let gpxFileName = route.gpxFileName {
                Label("GPX file: \(gpxFileName)", systemImage: "paperclip")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Label("Add a GPX file for this route next", systemImage: "square.and.arrow.down")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
