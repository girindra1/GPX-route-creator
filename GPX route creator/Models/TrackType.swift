//
//  TrackType.swift
//  GPX route creator
//

import SwiftUI

enum TrackType: String, CaseIterable, Identifiable, Codable {
    case loop
    case oneWay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .loop:
            return "Loop"
        case .oneWay:
            return "One Way"
        }
    }

    var description: String {
        switch self {
        case .loop:
            return "Loop rides finish back near the starting station."
        case .oneWay:
            return "One-way rides finish somewhere else, useful if you want a train-assisted return."
        }
    }

    var badgeTitle: String {
        switch self {
        case .loop:
            return "Loop"
        case .oneWay:
            return "One Way"
        }
    }

    var badgeColor: Color {
        switch self {
        case .loop:
            return .green
        case .oneWay:
            return .orange
        }
    }
}
