//
//  ParsedGPXFileCard.swift
//  GPX route creator
//

import SwiftUI

struct ParsedGPXFileCard: View {
    let file: ParsedGPXFile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(file.displayName)
                .font(.headline)

            Text(file.fileName)
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                Label("\(file.distanceKilometers.formatted(.number.precision(.fractionLength(1)))) km", systemImage: "figure.outdoor.cycle")
                Spacer()
                Label("\(file.elevationGainMeters) m", systemImage: "mountain.2")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            HStack {
                Label("\(file.segmentCount) segments", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                Spacer()
                Label("\(file.pointCount) points", systemImage: "point.3.connected.trianglepath.dotted")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
